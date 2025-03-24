//
//  MainTabBarControllerViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/12/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColors()
        setupTabs()
    }
    
    func setupColors() {
        self.tabBar.tintColor = UIColor(named: "CalendarColor")
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "CalendarColor")
    }
    
    func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "square.and.pencil"), tag: 0)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "gearshape"), tag: 2)
        
        viewControllers = [homeNav, searchNav, settingsNav]
    }
    
}
