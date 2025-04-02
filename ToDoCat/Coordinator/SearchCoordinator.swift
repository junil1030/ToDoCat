//
//  SearchCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/1/25.
//
import UIKit

class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: MainTabBarCoordinator?
    var navigationController: UINavigationController
    private let dataManager: ToDoDataManager

    init(navigationController: UINavigationController, dataManager: ToDoDataManager) {
        self.navigationController = navigationController
        self.dataManager = dataManager
    }

    func start() {
        let searchViewModel = SearchViewModel(dataManager: dataManager)
        let searchViewController = SearchViewController(viewModel: searchViewModel)

        searchViewModel.cellToDetailView = { [weak self] todoItem in
            self?.showDetailScreen(mode: .edit(todoItem), selectedDate: Date())
        }

        //searchViewController.setViewModel(searchViewModel)
        navigationController.pushViewController(searchViewController, animated: true)
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
