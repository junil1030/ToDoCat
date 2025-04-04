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

class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    private var homeViewModel: HomeViewModel
    
    private var cachedFilteredToDoList: [ToDoItem] = []
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
        
        homeViewModel.loadData() { [weak self] in
            self?.refreshData(reloadCalendar: true)
        }
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
        homeView.calendarView.didChangeHeight = { [weak self] newHeight in
            self?.adjustTableViewPosition(for: newHeight)
        }
        
        homeViewModel.onDateUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshData()
            }
        }
        
        homeViewModel.onToDoListUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshData(reloadCalendar: true)
            }
        }
    }
    
    @objc private func addNewEntry() {
        homeViewModel.addTaskButtonTapped()
    }
    
    // MARK: - Private Methods
    
    private func adjustTableViewPosition(for newHeight: CGFloat) {
        // 캘린더 높이에 따라 테이블 뷰 위치 조정
        homeView.toDoTableView.snp.updateConstraints { make in
            make.top.equalTo(homeView.calendarView.snp.bottom)
        }
        homeView.layoutIfNeeded() // 레이아웃 업데이트
    }
    
    private func refreshData(reloadCalendar: Bool = false) {
        if isRefreshing { return }
        isRefreshing = true
        
        // 백그라운드 스레드 사용 제거, 메인 스레드에서 직접 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let filteredList = self.homeViewModel.getFilteredToDoList()
            self.cachedFilteredToDoList = filteredList
            self.updateUI(reloadCalendar: reloadCalendar)
            self.isRefreshing = false
        }
    }
    
    private func updateUI(reloadCalendar: Bool = false) {
        homeView.toDoTableView.showEmptyState(cachedFilteredToDoList.isEmpty)
       
        // 캘린더는 필요할 때만 리로드
        if reloadCalendar {
            homeView.calendarView.reloadData()
        }
        
        homeView.toDoTableView.reloadData()
    }
}

//MARK: - FSCalendar Delegate & DataSource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeViewModel.updateSelectedDate(date)
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
            
            homeViewModel.deleteToDo(id: todo.id) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.refreshData()
                    case .failure:
                        self.view.makeToast("삭제에 실패했습니다. 다시 시도해주세요.")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let todo = self.cachedFilteredToDoList[indexPath.row]
            
            self.homeViewModel.deleteToDo(id: todo.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.refreshData()
                        completionHandler(true)
                    case .failure:
                        self.view.makeToast("삭제에 실패했습니다. 다시 시도해주세요.")
                        completionHandler(false)
                    }
                }
            }
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
        
        self.homeViewModel.toDoCellTapped(index: indexPath)
    }
}

