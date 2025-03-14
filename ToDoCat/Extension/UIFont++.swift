//
//  UIFont++.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//

import UIKit

struct AppFontName {
    static let dohyeon = "BMDoHyeon-OTF"
}

extension UIFont {
    class func dohyeon(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.dohyeon, size: size)!
    }
}
