//
//  Date++.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//
import UIKit

//MARK: - Date Extension

extension Date {
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "Asis/Seoul")
        return formatter.string(from: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }

    func toKST() -> Date {
        return Calendar.current.date(byAdding: .second,value: Common.korTimeZone.secondsFromGMT(for: self), to: self)!
    }
}
