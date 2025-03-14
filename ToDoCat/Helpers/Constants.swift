//
//  Constants.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//
import UIKit

struct Common {
    static var engTitle: String = "ToDoCat"
    static var korTitle: String = "매일할고양"
    
    static var fontName = "BMDOGYEON_otf"
    static func getUIFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: fontName, size: size)!
    }
}
