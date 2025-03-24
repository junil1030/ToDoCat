//
//  SettingsViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//
import UIKit

class SettingsViewModel {
    
    let sections = ["서비스", "정보"]
    
    var showResetAlert: (() -> Void)?
    var openMail: (() -> Void)?
    var showOpenSourceLicenses: (() -> Void)?
    var appVersion: String {
        print("버전: \(Constants.getAppVersion())")
        return Constants.getAppVersion()
    }
    
    lazy var items: [[SettingsOptionModel]] = [
        [
            SettingsOptionModel(title: "데이터 초기화", detail: nil) { [weak self] in
                self?.showResetAlert?()
            },
            SettingsOptionModel(title: "문의하기", detail: nil) { [weak self] in
                self?.openMail?()
            }
        ],
        [
            SettingsOptionModel(title: "오픈소스 라이브러리", detail: nil) { [weak self] in
                self?.showOpenSourceLicenses?()
            },
            SettingsOptionModel(title: "버전", detail: self.appVersion, action: nil)
        ]
    ]
}
