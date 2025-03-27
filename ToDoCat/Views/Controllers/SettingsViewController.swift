//
//  SettingsViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/24/25.
//

import UIKit
import AcknowList
import MessageUI

class SettingsViewController: UIViewController {
    
    private let settingsView = SettingsView()
    private let settingsViewModel = SettingsViewModel()
    
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
        settingsViewModel.showResetAlert = { [weak self] in self?.showResetAlert() }
        settingsViewModel.openMail = { [weak self] in self?.openMail() }
        settingsViewModel.showOpenSourceLicenses = { [weak self] in self?.showOpenSourceLicenses() }
    }
    
    private func showResetAlert() {
        let alert = UIAlertController(title: "데이터 초기화 시 기존 데이터는 전부 사라집니다."
                                      , message: "데이터 초기화를 진행할까요?"
                                      , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            if ToDoDataManager.shared.deleteToDoAll() {
                print("성공")
            } else {
                print("실패")
            }
        }))
        present(alert, animated: true)
    }
    
    private func openMail() {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            
            let bodyString = """
                                                 문의 사항 및 의견을 작성해주세요.
                                                 
                                                 
                                                 
                                                 
                                                 -------------------
                                                 
                                                 Device Model : \(Constants.getDeviceModelName())
                                                 Device OS : \(UIDevice.current.systemVersion)
                                                 App Version : \(Constants.getAppVersion())
                                                 
                                                 -------------------
                                                 """
            
            vc.setToRecipients(["dccrdseo@naver.com"])
            vc.setSubject("[\(Constants.engTitle)] 문의")
            vc.setMessageBody(bodyString, isHTML: false)
            
            self.present(vc, animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "'Mail' 앱을 찾을 수 없습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            sendMailErrorAlert.addAction(okAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    private func showOpenSourceLicenses() {
        let vc = AcknowListViewController()
        vc.navigationItem.title = "오픈소스 라이브러리"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = settingsViewModel.items[indexPath.section][indexPath.row]
        option.action?()
    }
}

//MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
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
}

//MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
