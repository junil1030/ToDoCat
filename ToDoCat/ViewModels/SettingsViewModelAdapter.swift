//
//  SettingsViewModelAdapter.swift
//  ToDoCat
//
//  Created by 서준일 on 5/21/25.
//

import RxSwift
import RxCocoa
import UIKit
import SwiftUI

class SettingsViewModelAdapter: ObservableObject {
    private let viewModel: SettingsViewModel
    private let disposeBag = DisposeBag()
    
    @Published var showingToast = false
    @Published var toastMessage = ""
    let appVersion: String
    
    var navigateToLicenses: (() -> Void)?
    var presentMail: (() -> Void)?
    var openReviewURL: (() -> Void)?
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        self.appVersion = Constants.getAppVersion()
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.resetResult
             .observe(on: MainScheduler.instance)
             .subscribe(onNext: { [weak self] message in
                 guard let self = self else { return }
                 self.toastMessage = message
                 self.showingToast = true
             })
             .disposed(by: disposeBag)
    }
    
    func resetConfirmed() {
        viewModel.resetAction.accept(())
    }
    
    func reviewButtonTapped() {
        viewModel.reviewAction.accept(())
    }
    
    func mailButtonTapped() {
        viewModel.openMailAction.accept(())
    }
    
    func openLicensesButtonTapped() {
        viewModel.openLicensesAction.accept(())
    }
}
