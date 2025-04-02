//
//  SettingsViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//
import UIKit

class SettingsViewModel {
    
    private let dataManager: ToDoDataDeletable
    
    let sections = ["서비스", "정보"]
    
    var showResetAlert: (() -> Void)?
    var showReview: (() -> Void)?
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
            SettingsOptionModel(title: "리뷰 남기기", detail: nil) { [weak self] in
                self?.showReview?()
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
    
    init(dataManager: ToDoDataDeletable) {
        self.dataManager = dataManager
    }
    
    func deleteToDoAll() {
        let result = dataManager.deleteToDoAll()
        
        switch result {
        case .success:
            print("삭제 완료")
        case .failure(let error):
            print("삭제에 실패했습니다. 에러: \(error)")
        }
    }
}
