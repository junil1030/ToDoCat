//
//  SearchViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//
import Foundation

class SearchViewModel {
    
    private let dataManager: ToDoDataSearchable
    
    var searchResult: [ToDoItem] = [] {
        didSet {
            onDataChanged?()
        }
    }
    var currentToDoItem: ToDoItem?

    var cellToDetailView: ((ToDoItem) -> Void)?
    var onDataChanged: (() -> Void)?
    
    init(dataManager: ToDoDataSearchable) {
        self.dataManager = dataManager
    }
    
    func search(keyword: String) {
        DispatchQueue.main.async { [weak self] in
            let result = self?.dataManager.searchToDos(keyword: keyword) ?? []
            self?.searchResult = result
        }
    }
    
    func toDoCellTapped(index: IndexPath) {
        currentToDoItem = searchResult[index.row]
        guard let currentToDoItem = currentToDoItem else { return }
        cellToDetailView?(currentToDoItem)
    }
}
