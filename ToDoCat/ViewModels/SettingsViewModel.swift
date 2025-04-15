//
//  SettingsViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//
import UIKit
import RxSwift
import RxCocoa

class SettingsViewModel {
    
    //MARK: - Properties
    private let dataManager: ToDoDataDeletable
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Data
    let sections = ["서비스", "정보"]
    
    //MARK: - Rx Stream
    // Action Event
    let resetAction = PublishRelay<Void>()
    let reviewAction = PublishRelay<Void>()
    let openMailAction = PublishRelay<Void>()
    let openLicensesAction = PublishRelay<Void>()
    
    let resetResult = PublishRelay<String>()
    let showAlert = PublishRelay<UIAlertController>()
    
    let version: String
    
    lazy var items: [[SettingsOptionModel]] = [
        [
            SettingsOptionModel(title: "데이터 초기화", detail: nil) { [weak self] in
                self?.resetAction.accept(())
            },
            SettingsOptionModel(title: "리뷰 남기기", detail: nil) { [weak self] in
                self?.reviewAction.accept(())
            },
            SettingsOptionModel(title: "문의하기", detail: nil) { [weak self] in
                self?.openMailAction.accept(())
            }
        ],
        [
            SettingsOptionModel(title: "오픈소스 라이브러리", detail: nil) { [weak self] in
                self?.openLicensesAction.accept(())
            },
            SettingsOptionModel(title: "버전", detail: self.version, action: nil)
        ]
    ]
    
    //MARK: - Initialization
    init(dataManager: ToDoDataDeletable) {
        self.dataManager = dataManager
        self.version = Constants.getAppVersion()
        setupBindings()
    }
    
    //MARK: - private Methods
    private func setupBindings() {
        // 데이터 초기화 액션 바인딩
        resetAction
            .map { [weak self] _ -> UIAlertController in
                let alert = UIAlertController(
                    title: "데이터 초기화 시 기존 데이터는 전부 사라집니다.",
                    message: "데이터 초기화를 진행할까요?",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [weak self] _ in
                    self?.performReset()
                }))
                
                return alert
            }
            .bind(to: showAlert)
            .disposed(by: disposeBag)
    }
    
    private func performReset() {
        dataManager.deleteToDoAll { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("삭제 완료")
                    self?.resetResult.accept("초기화가 완료되었습니다.")
                case .failure(let error):
                    print("삭제에 실패했습니다. 에러: \(error)")
                    self?.resetResult.accept("데이터 초기화에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    //MARK: - Public Methods
    // 리뷰 페이지
    func getReviewURL() -> URL? {
        return URL(string: "itms-apps://itunes.apple.com/app/id6743777075?action=write-review")
    }
    
    // 메일 설정 정보 가져오기
    func getMailSettings() -> (recipients: [String], subject: String, body: String) {
        let bodyString = """
                         문의 사항 및 의견을 작성해주세요.
                         
                         
                         
                         
                         -------------------
                         
                         Device Model : \(Constants.getDeviceModelName())
                         Device OS : \(UIDevice.current.systemVersion)
                         App Version : \(Constants.getAppVersion())
                         
                         -------------------
                         """
        
        return (["dccrdseo@naver.com"], "[\(Constants.engTitle)] 문의", bodyString)
    }
}
