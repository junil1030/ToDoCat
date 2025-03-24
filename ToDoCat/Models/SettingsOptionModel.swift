//
//  SettingsOption.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//

struct SettingsOptionModel {
    let title: String
    let detail: String?
    let action: (() -> Void)?
}
