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
    private var hasToDoForSelectedDate: Bool = false
    
    //MARK: - Callbacks
    var navigateToDetailView: (() -> Void)?
    var cellToDetailView: ((ToDoItem) -> Void)?
    var onDateUpdate: (() -> Void)?
    var onToDoListUpdated: (() -> Void)?
    
    //MARK: - Initaliztion
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.allToDoList = self.dataManager.getAllToDos()
            self.updateFilteredList()
            completion?()
        }
    }
    
    func getSelectedDate() -> Date {
        return selectedDate
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        updateFilteredList()
        
        onDateUpdate?()
    }
    
    func getFilteredToDoList() -> [ToDoItem] {
        return filteredToDoList
    }
    
    func hasEvent(for date: Date) -> Bool {
        let todosForDate = dataManager.getToDos(forDate: date)
        return !todosForDate.isEmpty
    }
    
    func addTaskButtonTapped() {
        navigateToDetailView?()
    }
    
    func toDoCellTapped(index: IndexPath) {
        //cellToDetailView?(filteredToDoList[index.row])
        let selectedToDo = filteredToDoList[index.row]
        cellToDetailView?(selectedToDo)
    }

    func deleteToDo(id: UUID) -> Result<Void, Error> {
        return dataManager.deleteToDo(id: id)
    }
    
    // MARK: - Private Methods
    private func updateFilteredList() {
        filteredToDoList = dataManager.getToDos(forDate: selectedDate)
//        print(filteredToDoList)
//        hasToDoForSelectedDate = !filteredToDoList.isEmpty
    }
}
