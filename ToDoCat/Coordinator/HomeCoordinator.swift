//
//  HomeCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/1/25.
//
import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: MainTabBarCoordinator?
    var navigationController: UINavigationController
    private let dataManager: ToDoDataManager

    init(navigationController: UINavigationController, dataManager: ToDoDataManager) {
        self.navigationController = navigationController
        self.dataManager = dataManager
    }

    func start() {
        let homeViewModel = HomeViewModel(dataManager: dataManager)
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        

        homeViewModel.navigateToDetailView = { [weak self] in
            guard let self = self else { return }
            self.showDetailScreen(mode: .new, selectedDate: homeViewModel.getSelectedDate())
        }

        homeViewModel.cellToDetailView = { [weak self] todoItem in
            guard let self = self else { return }
            self.showDetailScreen(mode: .edit(todoItem), selectedDate: homeViewModel.getSelectedDate())
        }

        //homeViewController.setViewModel(homeViewModel)
        //navigationController.viewControllers = [homeViewController]
        //navigationController.setViewControllers([homeViewController], animated: false)
        
        navigationController.pushViewController(homeViewController, animated: false)
        homeViewController.view.isUserInteractionEnabled = true
    }

    private func showDetailScreen(mode: DetailViewModel.Mode, selectedDate: Date) {
        let detailCoordinator = DetailCoordinator(navigationController: navigationController, dataManager: dataManager)
        detailCoordinator.parentCoordinator = self
        childCoordinators.append(detailCoordinator)
        detailCoordinator.start(mode: mode, selectedDate: selectedDate)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
