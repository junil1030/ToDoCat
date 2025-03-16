//
//  DateHelper.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//

import Foundation

struct DateHelper {
    static func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    static func currentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
