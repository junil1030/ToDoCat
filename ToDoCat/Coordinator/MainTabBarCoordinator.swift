//
//  MainTabBarCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/2/25.
//
import UIKit

class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: AppCoordinator?
    private let tabBarController: MainTabBarController
    private let dataManager: ToDoDataManager
    
    init(tabBarController: MainTabBarController, dataManager: ToDoDataManager) {
        self.tabBarController = tabBarController
        self.dataManager = dataManager
    }
    
    func start() {
        let homeNav = UINavigationController()
        let searchNav = UINavigationController()
        let settingsNav = UINavigationController()

        let homeCoordinator = HomeCoordinator(navigationController: homeNav, dataManager: dataManager)
        let searchCoordinator = SearchCoordinator(navigationController: searchNav, dataManager: dataManager)
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav, dataManager: dataManager)

        homeCoordinator.parentCoordinator = self
        searchCoordinator.parentCoordinator = self
        settingsCoordinator.parentCoordinator = self

        childCoordinators.append(homeCoordinator)
        childCoordinators.append(searchCoordinator)
        childCoordinators.append(settingsCoordinator)

        homeCoordinator.start()
        searchCoordinator.start()
        settingsCoordinator.start()
        
        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        searchNav.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        settingsNav.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 2)
        
        tabBarController.viewControllers = [homeNav, searchNav, settingsNav]
    }
    

    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
