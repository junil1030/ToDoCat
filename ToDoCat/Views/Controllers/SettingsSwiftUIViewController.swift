//
//  SettingsSwiftUIViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 5/21/25.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa
import AcknowList
import MessageUI

class SettingsSwiftUIViewController: UIViewController {
    
    private var hostingController: UIHostingController<SettingsSwiftUIView>!
    private var settingsViewModel: SettingsViewModel
    private var adapter: SettingsViewModelAdapter!
    private let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = SettingsViewModelAdapter(viewModel: settingsViewModel)
        setupNavigationHandlers()
        
        let swiftUIView = SettingsSwiftUIView(viewModel: adapter)
        hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
        
        setupBindings()
    }
    
    private func setupNavigationHandlers() {
        adapter.navigateToLicenses = { [weak self] in
            let vc = AcknowListViewController()
            vc.navigationItem.title = "오픈소스 라이브러리"
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        adapter.presentMail = { [weak self] in
            self?.openMail()
        }
        
        adapter.openReviewURL = { [weak self] in
            guard let reviewURL = self?.settingsViewModel.getReviewURL() else { return }
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
    
    private func setupBindings() {
        // 리뷰 액션 바인딩
        settingsViewModel.reviewAction
            .subscribe(onNext: { [weak self] _ in
                guard let reviewURL = self?.settingsViewModel.getReviewURL() else { return }
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        // 메일 액션 바인딩
        settingsViewModel.openMailAction
            .subscribe(onNext: { [weak self] _ in
                self?.openMail()
            })
            .disposed(by: disposeBag)
        
        // 오픈소스 액션 바인딩
        settingsViewModel.openLicensesAction
            .subscribe(onNext: { [weak self] _ in
                let vc = AcknowListViewController()
                vc.navigationItem.title = "오픈소스 라이브러리"
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func openMail() {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            
            let mailSettings = settingsViewModel.getMailSettings()
            vc.setToRecipients(mailSettings.recipients)
            vc.setSubject(mailSettings.subject)
            vc.setMessageBody(mailSettings.body, isHTML: false)
            
            self.present(vc, animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "'Mail' 앱을 찾을 수 없습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            sendMailErrorAlert.addAction(okAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
}

// Mail Compose 델리게이트 구현
extension SettingsSwiftUIViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
