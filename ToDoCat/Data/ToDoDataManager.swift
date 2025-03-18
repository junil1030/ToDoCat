//
//  ToDoDataManager.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//
import UIKit
import RealmSwift

//MARK: - ToDoData Manager
class ToDoDataManager {
    //MARK: - Singletone  패턴
    static let shared = ToDoDataManager()
    
    private init() {
        let realmConfig = Realm.Configuration(schemaVersion: 1)
        
        Realm.Configuration.defaultConfiguration = realmConfig
        
        print("realm 위치 \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    //MARK: - CRUD Methods
    func createToDo(todoItem: ToDoItem, isComplete: Bool = false) -> Bool {
        let realm = try! Realm()
        
        do {
            let realmItem = ToDoItemRealm(toDoItem: todoItem)
            try realm.write {
                realm.add(realmItem)
            }
            return true
        } catch {
            print("Error creating todo: \(error)")
            return false
        }
    }
    
    func getToDo(by id: UUID) -> ToDoItem? {
        let realm = try! Realm()
        
        guard let realmItem = realm.object(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else { return nil }
         
        return realmItem.toToDoItem()
    }
    
    func getToDos(forDate date: Date) -> [ToDoItem] {
        let realm = try! Realm()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let realmItems = realm.objects(ToDoItemRealm.self)
            .filter("createdAt >= %@ AND createdAt < %@", startOfDay, endOfDay)
        
        return realmItems.map { $0.toToDoItem() }
    }
    
    func getAllToDos() -> [ToDoItem] {
        let realm = try! Realm()
        
        let realmResults = realm.objects(ToDoItemRealm.self).sorted(byKeyPath: "createdAt", ascending: true)
                
        return realmResults.map { $0.toToDoItem() }
    }
    
    func updateToDo(id: UUID, content: String, image: UIImage?) -> Bool {
        let realm = try! Realm()
        
        guard let todoToUpdate = realm.object(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else { return false }
        
        do {
            try realm.write {
                todoToUpdate.content = content
                
                if let newImage = image {
                    todoToUpdate.imageData = newImage.jpegData(compressionQuality: 0.7)
                } else {
                    todoToUpdate.imageData = nil
                }
                
                todoToUpdate.updatedAt = Date()
            }
            return true
            
        } catch {
            print("Error updating ToDo: \(error)")
            return false
        }
    }
    
    func toggleCompletion(id: UUID) -> Bool {
        let realm = try! Realm()
        
        guard let todoToUpdate = realm.object(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else { return false }
        
        do {
            try realm.write {
                todoToUpdate.isCompleted = !todoToUpdate.isCompleted
                todoToUpdate.updatedAt = Date()
            }
            return true
            
        } catch {
            print("Error toggling Completion: \(error)")
            return false
        }
    }
    
    func deleteToDo(id: UUID) -> Bool {
        let realm = try! Realm()
        
        guard let todoToDelete = realm.object(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else { return false }
        
        do {
            try realm.write {
                realm.delete(todoToDelete)
            }
            return true
            
        } catch {
            print("Error toggling Completion: \(error)")
            return false
        }
    }
    
    func deleteToDos(forDate date: Date) -> Bool {
        let realm = try! Realm()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let todosToDelete = realm.objects(ToDoItemRealm.self).filter("createdAt >= %@ AND createdAt < %@", startOfDay, endOfDay)
        
        do {
            try realm.write {
                realm.delete(todosToDelete)
            }
            return true
            
        } catch {
            print("Error deleting todos for date: \(error)")
            return false
        }
    }
}
