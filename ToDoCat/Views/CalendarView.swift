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

    let calendarView: FSCalendar = {
        var calendar = FSCalendar()
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .gray
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.selectionColor = .systemBlue
        calendar.appearance.todayColor = .systemBlue.withAlphaComponent(0.3)
        calendar.appearance.todaySelectionColor = .systemBlue
        calendar.appearance.headerDateFormat = "yyyy년 MM월"
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 14)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        calendar.scrollDirection = .horizontal
        calendar.pagingEnabled = true
        calendar.allowsMultipleSelection = false
        calendar.clipsToBounds = true
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .white
        
        addSubview(calendarView)
        
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
