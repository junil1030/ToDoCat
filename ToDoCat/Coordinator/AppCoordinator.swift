//
//  AppCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/1/25.
//

import UIKit
import RealmSwift

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func removeChild(_ coordinator: Coordinator)
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let dataManager: ToDoDataManager

    init() {
        // RealmManager 초기화
        let realmManager: RealmManageable
        do {
            realmManager = try RealmManager(configuration: Realm.Configuration(schemaVersion: 1))
        } catch {
            fatalError("Realm 초기화 실패: \(error)")
        }

        // ToDoDataManager 초기화
        self.dataManager = ToDoDataManager(realmManager: realmManager)
    }

    func start() -> UIViewController {
        let mainTabBarController = MainTabBarController()
        
        let tabBarCoordinator = MainTabBarCoordinator(tabBarController: mainTabBarController, dataManager: dataManager)
        tabBarCoordinator.parentCoordinator = self
        
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        
        return mainTabBarController
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
