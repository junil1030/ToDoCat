//
//  DetailCoordinator.swift
//  ToDoCat
//
//  Created by 서준일 on 4/2/25.
//

import UIKit

class DetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    private let dataManager: ToDoDataManager

    init(navigationController: UINavigationController, dataManager: ToDoDataManager) {
        self.navigationController = navigationController
        self.dataManager = dataManager
    }
    
    func start() {
        fatalError("DetailCoordinator는 start(mode:selectedDate:)를 사용해야 합니다.")
    }

    func start(mode: DetailViewModel.Mode, selectedDate: Date) {
        let detailViewModel = DetailViewModel(mode: mode, selectedDate: selectedDate, dataManager: dataManager)
        
        detailViewModel.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.navigationController.popViewController(animated: true)
            self.parentCoordinator?.removeChild(self)
        }

        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
