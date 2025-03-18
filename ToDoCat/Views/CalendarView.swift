//
//  CalendarView.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//

import UIKit
import FSCalendar
import SnapKit

class CalendarView: UIView {
    
    private lazy var calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .gray
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.selectionColor = .systemBlue
        calendar.appearance.todayColor = .systemBlue.withAlphaComponent(0.3)
        calendar.appearance.todaySelectionColor = .systemBlue
        calendar.appearance.headerDateFormat = "yyyy년 MM월"
        calendar.appearance.headerTitleFont = UIFont.dohyeon(size: 16)
        calendar.appearance.titleFont = UIFont.dohyeon(size: 14)
        calendar.appearance.weekdayFont = UIFont.dohyeon(size: 14)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .horizontal
        calendar.pagingEnabled = true
        calendar.allowsMultipleSelection = false
        calendar.clipsToBounds = true
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private var calendarHeightConstraint: Constraint?
    private let weekHeight: CGFloat = 150
    private let monthHeight: CGFloat = 300
    
    var didChangeHeight: ((CGFloat) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(calendarView)
        
        calendarView.scope = .month
        calendarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            calendarHeightConstraint = make.height.equalTo(monthHeight).constraint
        }
    }
    
    private func setupGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self
                                                          , action: #selector(panGestureHandler))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGestureHandler(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if gesture.state == .ended {
            if translation.y < -50 {
                calendarView.setScope(.week, animated: true) // 위로 스크롤 시 주간
                updateHeight(weekHeight)
            } else if translation.y > 50 {
                calendarView.setScope(.month, animated: true) // 아래로 스크롤 시 월간
                updateHeight(monthHeight)
            }
        }
    }
    
    // MARK: - Public Methods
    func setDelegate(_ delegate: FSCalendarDelegate & FSCalendarDataSource) {
        calendarView.delegate = delegate
        calendarView.dataSource = delegate
    }
    
    func selectDate(_ date: Date) {
        calendarView.select(date, scrollToDate: true)
    }
    
    func updateCalendarScope(_ scope: FSCalendarScope) {
        calendarView.setScope(scope, animated: true)
        let newHeight = (scope == .week) ? weekHeight : monthHeight
        updateHeight(newHeight)
    }
    
    func updateHeight(_ height: CGFloat) {
        calendarHeightConstraint?.update(offset: height)
    }
    
    func reloadData() {
        calendarView.reloadData()
    }
}
