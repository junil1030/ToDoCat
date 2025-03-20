//
//  SearchViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//
import Foundation

class SearchViewModel {
    
    var searchResult: [ToDoItem] = [] {
        didSet {
            onDataChanged?()
        }
    }
    var currentToDoItem: ToDoItem?

    var cellToDetailView: ((ToDoItem) -> Void)?
    var onDataChanged: (() -> Void)?
    
    func search(keyword: String) {
        DispatchQueue.global().async { [weak self] in
            let result = ToDoDataManager.shared.searchToDos(keyword: keyword)
            
            DispatchQueue.main.async {
                self?.searchResult = result
            }
        }
    }
    
    func toDoCellTapped(index: IndexPath) {
        currentToDoItem = searchResult[index.row]
        guard let currentToDoItem = currentToDoItem else { return }
        cellToDetailView?(currentToDoItem)
    }
}
