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
    
    private let dateSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = UIColor(named: "CalendarColor")
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    private let todayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar.badge.clock"), for: .normal)
        button.tintColor = UIColor(named: "CalendarColor")
        return button
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    private lazy var datePickerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = UIColor(named: "CalendarColor")
        return picker
    }()
    
    private lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택완료", for: .normal)
        button.titleLabel?.font = UIFont.dohyeon(size: 16)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var calendarHeightConstraint: Constraint?
    private let weekHeight: CGFloat = 150
    private let monthHeight: CGFloat = 300
    
    var didChangeHeight: ((CGFloat) -> Void)?
    var onDateSelected: ((Date) -> Void)?
    
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
        addSubview(dateSelectButton)
        
        addSubview(overlayView)
        overlayView.addSubview(datePickerContainerView)
        datePickerContainerView.addSubview(datePicker)
        datePickerContainerView.addSubview(selectButton)
        
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
        
        dateSelectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        // 오버레이 레이아웃
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        datePickerContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.8)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        selectButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        // 오버레이 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    private func setupGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self
                                                          , action: #selector(panGestureHandler))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupActions() {
        todayButton.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        dateSelectButton.addTarget(self, action: #selector(dateSelectButtonTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    @objc private func todayButtonTapped() {
        selectDate(Date())
        onDateSelected?(Date())
    }
    
    @objc private func dateSelectButtonTapped() {
        showDatePicker()
    }
    
    @objc private func overlayTapped() {
        hideDatePicker()
    }
    
    @objc private func selectButtonTapped() {
        let selectedDate = datePicker.date
        selectDate(selectedDate)
        onDateSelected?(selectedDate)
        hideDatePicker()
    }
    
    // DatePicker 표시
    private func showDatePicker() {
        datePicker.date = calendarView.selectedDate ?? Date()
        overlayView.isHidden = false
        overlayView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1
        }
    }
    
    // DatePicker 숨기기
    private func hideDatePicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 0
        }) { _ in
            self.overlayView.isHidden = true
        }
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
