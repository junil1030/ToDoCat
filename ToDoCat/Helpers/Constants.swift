//
//  Constants.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//
import UIKit

struct Constants {
    static var engTitle: String = "ToDoCat"
    static var korTitle: String = "매일할고양"
    
    static func getCatImageUrl(says: String?) -> String {
        guard let says = says else {
            return "https://cataas.com/cat?width=400&height=400"
        }
        return "https://cataas.com/cat/says/\(says)?width=400&height=400"
    }
}
