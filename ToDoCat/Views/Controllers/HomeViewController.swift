//
//  HomeViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/12/25.
//

import UIKit
import SnapKit
import FSCalendar
import RealmSwift
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    private var homeViewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private var isRefreshing = false // 중복 리프레시 방지용
    
    init(viewModel: HomeViewModel) {
        self.homeViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupDelegates()
        setupBindings()
        
        homeView.calendarView.selectDate(Date())
        homeViewModel.loadDataTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentDate = homeViewModel.getSelectedDate()
        homeViewModel.selectedDateTrigger.accept(currentDate)
    }
    
    //MARK: - Setup Methods
    private func setupNavigationBar() {
        let rigthButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewEntry)
        )
        navigationItem.rightBarButtonItem = rigthButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CalendarColor")
    }
    
    private func setupDelegates() {
        homeView.calendarView.setDelegate(self)
        homeView.toDoTableView.setDelegate(self)
    }
    
    private func setupBindings() {
        // 캘린더 높이
        homeView.calendarView.didChangeHeight = { [weak self] newHeight in
            self?.adjustTableViewPosition(for: newHeight)
        }
        
        // 날짜 변경 시 해당 데이터 리로드
        homeView.calendarView.onDateSelected = { [weak self] date in
            self?.homeViewModel.selectedDateTrigger.accept(date)
        }
        
        // 필터링된 ToDo리스트
        homeViewModel.filteredToDoItems
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.updateUI(with: items)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        homeViewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 메세지
        homeViewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message)
            })
            .disposed(by: disposeBag)
        
        // 성공 메세지
        homeViewModel.success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message)
            })
            .disposed(by: disposeBag)
        
        // 새 항목 추가
        homeViewModel.showDetailForNewItem
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                self?.navigateToDetail(mode: .new, selectedDate: date)
            })
            .disposed(by: disposeBag)
        
        // 기존 항목 편집
        homeViewModel.showDetailForExistingItem
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] todoItem in
                self?.navigateToDetail(mode: .edit(todoItem), selectedDate: self?.homeViewModel.getSelectedDate() ?? Date())
            })
            .disposed(by: disposeBag)
        
        // 캘린더 이벤트
        homeViewModel.hasEvents
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.homeView.calendarView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func addNewEntry() {
        homeViewModel.addNewItemTrigger.accept(())
    }
    
    // MARK: - Private Methods
    private func adjustTableViewPosition(for newHeight: CGFloat) {
        // 캘린더 높이에 따라 테이블 뷰 위치 조정
        homeView.toDoTableView.snp.updateConstraints { make in
            make.top.equalTo(homeView.calendarView.snp.bottom)
        }
        homeView.layoutIfNeeded() // 레이아웃 업데이트
    }
    
    private func updateUI(with items: [ToDoItem]) {
        homeView.toDoTableView.showEmptyState(items.isEmpty)
        homeView.toDoTableView.reloadData()
    }
    
    private func navigateToDetail(mode: DetailViewModel.Mode, selectedDate: Date) {
        switch mode {
        case .edit(let item):
            homeViewModel.cellToDetailView?(item)
        case .new:
            homeViewModel.navigateToDetailView?()
        }
    }
}

//MARK: - FSCalendar Delegate & DataSource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeViewModel.selectedDateTrigger.accept(date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return homeViewModel.checkHasEvent(for: date) ? 1 : 0
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            // 새로 변경될 캘린더의 높이
            let newHeight = bounds.height
            self.homeView.calendarView.snp.updateConstraints { make in
                make.height.equalTo(newHeight)
            }
            // 테이블 뷰의 top 제약 조건을 변경
            self.homeView.toDoTableView.snp.updateConstraints { make in
                make.top.equalTo(self.homeView.calendarView.snp.bottom)
            }
            // 레이아웃 적용
            self.homeView.layoutIfNeeded()
        }
    }
}

//MARK: - UITabelView Delegate & DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.filteredToDoItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let items = homeViewModel.filteredToDoItems.value
        guard indexPath.row < items.count else { return cell }
        
        let entry = items[indexPath.row]
        cell.configure(with: entry)
        cell.accessoryType = .disclosureIndicator
        
        cell.onCheckBoxToggle = { [weak self] in
            cell.checkBoxButton.isSelected = !cell.checkBoxButton.isSelected
            self?.homeViewModel.toggleCompletionTrigger.accept(entry.id)
        }
        
        return cell
    }
    
    // 삭제 버튼 활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let items = self.homeViewModel.filteredToDoItems.value
            guard indexPath.row < items.count else {
                completionHandler(false)
                return
            }
            
            let todo = items[indexPath.row]
            self.homeViewModel.deleteItemTrigger.accept(todo.id)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        homeViewModel.selectItemTrigger.accept(indexPath)
    }
}

