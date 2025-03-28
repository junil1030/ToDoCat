//
//  HomeViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/12/25.
//

import UIKit
import SnapKit
import FSCalendar

class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    private let homeViewModel = HomeViewModel()
    
    private let detailView = DetailView()
    
    private var cachedFilteredToDoList: [ToDoItem] = []
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupDelegates()
        setupBindings()
        
        homeView.calendarView.selectDate(Date())
        
        homeViewModel.loadData() { [weak self] in
            self?.refreshData()
        }
    }
    
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
        homeView.calendarView.didChangeHeight = { [weak self] newHeight in
            self?.adjustTableViewPosition(for: newHeight)
        }
        
        homeViewModel.navigateToDetailView = { [weak self] in
            self?.showDetailView(mode: .new)
        }
        
        homeViewModel.cellToDetailView = { [weak self] toDoItem in
            self?.showDetailView(mode: .edit(toDoItem))
        }
        
        homeViewModel.onDateUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshData()
            }
        }
    }
    
    @objc private func addNewEntry() {
        homeViewModel.addTaskButtonTapped()
    }
    
    // MARK: - Private Methods
    private func showDetailView(mode: DetailViewModel.Mode) {
        let detailViewController = DetailViewController(
            mode: mode,
            selectedDate: homeViewModel.getSelectedDate()
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func adjustTableViewPosition(for newHeight: CGFloat) {
        // 캘린더 높이에 따라 테이블 뷰 위치 조정
        homeView.toDoTableView.snp.updateConstraints { make in
            make.top.equalTo(homeView.calendarView.snp.bottom)
        }
        homeView.layoutIfNeeded() // 레이아웃 업데이트
    }
    
    private func refreshData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredList = self.homeViewModel.getFilteredToDoList()
            DispatchQueue.main.async {
                self.cachedFilteredToDoList = filteredList
                self.updateUI()
            }
        }
    }
    
    private func updateUI() {
        homeView.toDoTableView.showEmptyState(cachedFilteredToDoList.isEmpty)
        homeView.calendarView.reloadData()
        homeView.toDoTableView.reloadData()
        
        homeViewModel.updateSelectedDate(homeViewModel.getSelectedDate())
    }
}

//MARK: - FSCalendar Delegate & DataSource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeViewModel.updateSelectedDate(date)
        print("선택한 날짜: \(date.toString())")
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let hasEvent = homeViewModel.hasEvent(for: date)
        return hasEvent ? 1 : 0
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
        return cachedFilteredToDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let entry = cachedFilteredToDoList[indexPath.row]
        cell.configure(with: entry)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // 삭제 버튼 활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = cachedFilteredToDoList[indexPath.row]
            if ToDoDataManager.shared.deleteToDo(id: todo.id) {
                DispatchQueue.main.async {
                    self.updateUI()
                }
            } else {
                view.makeToast("삭제에 실패했습니다. 다시 시도해주세요.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            if let todo = self?.cachedFilteredToDoList[indexPath.row] {
                
                if ToDoDataManager.shared.deleteToDo(id: todo.id) {
                    DispatchQueue.main.async {
                        self?.updateUI()
                    }
                    completionHandler(true)
                } else {
                    view.makeToast("삭제에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
        
        // 삭제 버튼 커스터마이징 (옵션)
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        // 스와이프 액션 구성
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.homeViewModel.toDoCellTapped(index: indexPath)
    }
}

