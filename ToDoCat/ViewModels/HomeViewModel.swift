//
//  HomeViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//
import UIKit

class HomeViewModel {
    
    //MARK: - Properties
    private var dataManager: ToDoDataFetchable & ToDoDataDeletable & ToDoDataObserver
    private var allToDoList: [ToDoItem] = []
    private var selectedDate: Date = Date()
    private var filteredToDoList: [ToDoItem] = []
    private var isLoading: Bool = false
    
    //MARK: - Callbacks
    var navigateToDetailView: (() -> Void)?
    var cellToDetailView: ((ToDoItem) -> Void)?
    var onDateUpdate: (() -> Void)?
    var onToDoListUpdated: (() -> Void)?
    
    //MARK: - Initialization
    init(dataManager: ToDoDataFetchable & ToDoDataDeletable & ToDoDataObserver) {
        self.dataManager = dataManager
        setupBindings()
    }
    
    //MARK: - Bindings
    func setupBindings() {
        dataManager.onDataChanged = { [weak self] in
            guard let self = self else { return }
            
            self.loadData {
                self.onToDoListUpdated?()
            }
        }
    }
    
    //MARK: - Data Handling
    func loadData(completion: (() -> Void)? = nil) {
        // 동시에 여러 번 호출되는 것 방지
        guard !isLoading else {
            completion?()
            return
        }
        
        isLoading = true
        
        dataManager.getAllToDos { [weak self] todos in
            guard let self = self else { return }
            
            self.allToDoList = todos
            self.updateFilteredList()
            self.isLoading = false
            completion?()
        }
    }
    
    func getSelectedDate() -> Date {
        return selectedDate
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        
        // 비동기로 필터링된 목록 업데이트
        dataManager.getToDos(forDate: date) { [weak self] todos in
            guard let self = self else { return }
            
            self.filteredToDoList = todos
            self.onDateUpdate?()
        }
    }
    
    func getFilteredToDoList() -> [ToDoItem] {
        return filteredToDoList
    }
    
    func hasEvent(for date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        return allToDoList.contains { todo in
            calendar.isDate(calendar.startOfDay(for: todo.date), inSameDayAs: targetDate)
        }
    }
    
    func addTaskButtonTapped() {
        navigateToDetailView?()
    }
    
    func toDoCellTapped(index: IndexPath) {
        let selectedToDo = filteredToDoList[index.row]
        cellToDetailView?(selectedToDo)
    }

    func deleteToDo(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        dataManager.deleteToDo(id: id) { result in
            completion(result)
        }
    }
    
    // MARK: - Private Methods
    private func updateFilteredList() {
        dataManager.getToDos(forDate: selectedDate) { [weak self] todos in
            guard let self = self else { return }
            
            self.filteredToDoList = todos
        }
    }
}
