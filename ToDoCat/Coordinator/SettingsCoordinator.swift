//
//  SettingsCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/1/25.
//
import UIKit

class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    private let dataManager: ToDoDataManager

    init(navigationController: UINavigationController, dataManager: ToDoDataManager) {
        self.navigationController = navigationController
        self.dataManager = dataManager
    }

    func start() {
        let settingsViewModel = SettingsViewModel(dataManager: dataManager)
        let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
        //navigationController.viewControllers = [settingsViewController]
        
        navigationController.pushViewController(settingsViewController, animated: false)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
