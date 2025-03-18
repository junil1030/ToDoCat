//
//  HomeViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//
import UIKit

class HomeViewModel {
    
    //MARK: - Properties
    private var allToDoList: [ToDoItem] = []
    private var selectedDate: Date = Date()
    private var filteredToDoList: [ToDoItem] = []
    private var hasToDoCache: Bool = false
    
    var navigateToDetailView: (() -> Void)?
    var onDateUpdate: (() -> Void)?
    
    //MARK: - Methods
    init() {
        loadData {
            self.onDateUpdate?()
        }
    }
    
    func printAllToDoList() {
        for num in 0..<allToDoList.count {
            print("content: \(allToDoList[num].content), createdAt: \(allToDoList[num].createdAt)")
            
        }
    }
    
    func loadData(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let todos = ToDoDataManager.shared.getAllToDos()
            
            DispatchQueue.main.async { [weak self] in
                self?.allToDoList = todos
                completion()
            }
        }
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        filterToDoList()
    }

    func addTaskButtonTapped() {
        navigateToDetailView?()
    }
    
    func hasEvent(for date: Date) -> Bool {
        let calendar = Calendar.current
        return allToDoList.contains {
            return calendar.isDate($0.createdAt, inSameDayAs: date.toKST())
        }
    }
    
    func getFilteredToDoList() -> [ToDoItem] {
        return filteredToDoList
    }
    
    //MARK: - Private Methods
    private func filterToDoList() {
        let calendar = Calendar.current
        let strippedSelectedDate = calendar.startOfDay(for: selectedDate)
        
        let newFilteredList = allToDoList.filter {
            let strippedCreatedAt = calendar.startOfDay(for: $0.createdAt)
            return strippedCreatedAt == strippedSelectedDate
        }
        
        if filteredToDoList != newFilteredList {
            filteredToDoList = newFilteredList
            updateToDoCache()
            onDateUpdate?()
        }
    }
    
    private func updateToDoCache() {
        hasToDoCache = !filteredToDoList.isEmpty
    }
}
