//
//  String++.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//
import Foundation

//MARK: - String Extension
extension String {
    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
