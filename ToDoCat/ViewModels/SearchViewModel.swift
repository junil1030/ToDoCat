//
//  SearchViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//
import Foundation

class SearchViewModel {
    
    private let dataManager: ToDoDataSearchable
    private var isSearching = false
    
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
        // 이미 검색 중이면 return
        guard !isSearching else { return }
        
        // 검색어가 너무 짧으면 검색하지 않음
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchResult = []
            return
        }
        
        isSearching = true
        
        dataManager.searchToDos(keyword: keyword) { [weak self] results in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.searchResult = results
                self.isSearching = false
            }
        }
    }
    
    func toDoCellTapped(index: IndexPath) {
        guard index.row < searchResult.count else { return }
        
        currentToDoItem = searchResult[index.row]
        guard let currentToDoItem = currentToDoItem else { return }
        cellToDetailView?(currentToDoItem)
    }
}
