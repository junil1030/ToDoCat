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
    
    override func loadView() {
        view = homeView
        
        //view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupDelegates()
        
        homeViewModel.loadData()
        updateListView()
        
        setupBindings()

    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewEntry)
        )
    }
    
    private func setupDelegates() {
        // 캘린더 델리게이트 설정
        homeView.calendarView.setDelegate(self)
        
        // 리스트뷰 델리게이트 설정
        homeView.toDoTableView.setDelegate(self)
    }
    
    private func setupBindings() {
        homeView.calendarView.didChangeHeight = { [weak self] newHeight in
            self?.adjustTableViewPosition(for: newHeight)
        }
        
        homeViewModel.navigateToDetailView = { [weak self] in
            let detailViewController = DetailViewController()
            self?.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    @objc private func addNewEntry() {
        homeViewModel.addTaskButtonTapped()
    }
    
    // 샘플 이미지 생성 (실제 앱에서는 사용자가 제공하는 이미지 사용)
    private func createSampleImage(withColor color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 60, height: 60))
        }
    }
    
    // MARK: - Private Methods
    private func adjustTableViewPosition(for newHeight: CGFloat) {
        // 캘린더 높이에 따라 테이블 뷰 위치 조정
        homeView.toDoTableView.snp.updateConstraints { make in
            make.top.equalTo(homeView.calendarView.snp.bottom)
        }
        homeView.layoutIfNeeded() // 레이아웃 업데이트
    }
    
    private func updateListView() {
        homeView.toDoTableView.showEmptyState(homeViewModel.filteredToDoList.isEmpty)
        homeView.toDoTableView.reloadData()
    }
}

//MARK: - FSCalendar Delegate & DataSource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeViewModel.updateSelectedDate(date)
        updateListView()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let hasToDo = homeViewModel.filteredToDoList.contains(where: { $0.date == date })
        return hasToDo ? 1 : 0
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
        return homeViewModel.filteredToDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let entry = homeViewModel.filteredToDoList[indexPath.row]
        cell.configure(with: entry)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("화면이동")
    }
}
