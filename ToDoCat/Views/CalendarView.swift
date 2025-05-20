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
        calendar.appearance.headerTitleColor = UIColor(named: "TextColor")
        calendar.appearance.weekdayTextColor = UIColor(named: "TextColor")
        calendar.appearance.titleDefaultColor = UIColor(named: "TextColor")
        calendar.appearance.selectionColor = UIColor(named: "CalendarColor")
        calendar.appearance.todayColor = UIColor(named: "CalendarColor")!.withAlphaComponent(0.3)
        calendar.appearance.todaySelectionColor = UIColor(named: "CalendarColor")
        calendar.appearance.eventDefaultColor = UIColor(named: "CalendarColor")
        calendar.appearance.eventSelectionColor = UIColor(named: "CalendarColor")
        calendar.appearance.headerDateFormat = "yyyy년 MM월"
        calendar.appearance.headerTitleFont = UIFont.dohyeon(size: 16)
        calendar.appearance.titleFont = UIFont.dohyeon(size: 14)
        calendar.appearance.weekdayFont = UIFont.dohyeon(size: 14)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .horizontal
        calendar.pagingEnabled = true
        calendar.allowsMultipleSelection = false
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.clipsToBounds = true
        return calendar
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .automatic
        picker.backgroundColor = .clear
        picker.tintColor = UIColor(named: "CalendarColor")
        return picker
    }()
    
    private let dateSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = UIColor(named: "CalendarColor")
        return button
    }()
    
    private let todayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar.badge.clock"), for: .normal)
        button.tintColor = UIColor(named: "CalendarColor")
        return button
    }()
    
    private var calendarHeightConstraint: Constraint?
    private let weekHeight: CGFloat = 150
    private let monthHeight: CGFloat = 300
    
    var didChangeHeight: ((CGFloat) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "BackgroundColor")
        
        addSubview(calendarView)
        addSubview(todayButton)
        addSubview(datePicker)
        
        calendarView.scope = .month
        
        calendarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            calendarHeightConstraint = make.height.equalTo(monthHeight).constraint
        }
        
        todayButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        datePicker.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(130)
            make.height.equalTo(35)
        }
    }
    
    private func setupGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self
                                                          , action: #selector(panGestureHandler))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupActions() {
        todayButton.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func todayButtonTapped() {
        print("todayButton")
        selectDate(Date())
    }
    
    @objc private func datePickerValueChanged() {
        print("datePickerValueChanged")
        selectDate(datePicker.date)
        
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
