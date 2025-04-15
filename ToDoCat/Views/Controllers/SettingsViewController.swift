//
//  SettingsViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//

import UIKit
import AcknowList
import MessageUI
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController {
    
    private let settingsView: SettingsView
    private var settingsViewModel: SettingsViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
        self.settingsView = SettingsView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = settingsView
        
        setupDelegates()
        setupBindings()
    }
    
    private func setupDelegates() {
        settingsView.tableView.delegate = self
        settingsView.tableView.dataSource = self
        settingsView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupBindings() {
        
        // 알림창
        settingsViewModel.showAlert
            .subscribe(onNext: { [weak self] alert in
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 초기화 결과 토스트 메세지
        settingsViewModel.resetResult
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message)
            })
            .disposed(by: disposeBag)
        
        // 리뷰 페이지 열기
        settingsViewModel.reviewAction
            .subscribe(onNext: { [weak self] _ in
                guard let reviceURL = self?.settingsViewModel.getReviewURL() else { return }
                UIApplication.shared.open(reviceURL, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        // 메일 보내기
        settingsViewModel.openMailAction
            .subscribe(onNext: { [weak self] _ in
                self?.openMail()
            })
            .disposed(by: disposeBag)
        
        // 오픈소스 표시
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


// MARK: - UITableViewDelegate, UITableViewDataSource
// 테이블 뷰의 내용이 고정적이고 입력에 따라 변화하지 않기 때문에
// Rx로 구독하는 것보다 델리게이트를 사용하는 것이 효율적이라 판단
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsViewModel.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let option = settingsViewModel.items[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = option.title
        cell.detailTextLabel?.text = option.detail
        cell.accessoryType = option.action == nil ? .none : .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsViewModel.sections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = settingsViewModel.items[indexPath.section][indexPath.row]
        option.action?()
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
