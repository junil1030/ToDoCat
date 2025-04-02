//
//  ToDoDataManager.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//
import UIKit
import RealmSwift

// MARK: - RealmManageable Protocol
protocol RealmManageable {
    func getObject<T: Object>(ofType type: T.Type, forPrimaryKey key: String) -> T?
    func getObjects<T: Object>(_ type: T.Type) -> Results<T>
    func getFilteredObjects<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Results<T>
    func getSortedObjects<T: Object>(_ type: T.Type, sortedByKeyPath keyPath: String, ascending: Bool) -> Results<T>
    func write<T>(_ block: () throws -> T) throws -> T
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy) throws
    func delete<T: Object>(_ object: T) throws
    func deleteAll<T: Object>(_ objects: Results<T>) throws
    func observeChanges<T: Object>(for type: T.Type, completion: @escaping (RealmCollectionChange<Results<T>>) -> Void) -> NotificationToken
}

// MARK: - Realm 구현
class RealmManager: RealmManageable {
    private let realm: Realm
    
    init(configuration: Realm.Configuration = Realm.Configuration(schemaVersion: 1)) throws {
        realm = try Realm(configuration: configuration)
        print("Realm 위치: \(configuration.fileURL?.absoluteString ?? "Unknown")")
    }
    
    func getObject<T: Object>(ofType type: T.Type, forPrimaryKey key: String) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    func getObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func getFilteredObjects<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func getSortedObjects<T: Object>(_ type: T.Type, sortedByKeyPath keyPath: String, ascending: Bool) -> Results<T> {
        return realm.objects(type).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    func write<T>(_ block: () throws -> T) throws -> T {
        try realm.write(block)
    }
    
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) throws {
        try realm.write {
            realm.add(object, update: update)
        }
    }
    
    func delete<T: Object>(_ object: T) throws {
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll<T: Object>(_ objects: Results<T>) throws {
        try realm.write {
            realm.delete(objects)
        }
    }
    
    func observeChanges<T: Object>(for type: T.Type, completion: @escaping (RealmCollectionChange<Results<T>>) -> Void) -> NotificationToken {
        let results = realm.objects(type)
        return results.observe(completion)
    }
}

//MARK: - ToDoData Protocol
protocol ToDoDataFetchable {
    func getAllToDos() ->[ToDoItem]
    func getToDos(forDate date: Date) -> [ToDoItem]
}

protocol ToDoDataSearchable {
    func searchToDos(keyword: String) -> [ToDoItem]
}

protocol ToDoDataEditable {
    func createToDo(todoItem: ToDoItem) -> Result<Void, Error>
    func updateToDo(id: UUID, content: String, image: UIImage?) -> Result<Void, Error>
    func toggleCompletion(id: UUID) -> Result<Void, Error>
}

protocol ToDoDataDeletable {
    func deleteToDo(id: UUID) -> Result<Void, Error>
    func deleteToDoAll() -> Result<Void, Error>
}

protocol ToDoDataObserver {
    var onDataChanged: (() -> Void)? { get set }
}

// MARK: - 에러
enum ToDoDataError: Error {
    case realmError(Error)
    case itemNotFound
    case invalidData
    case unknown
}

//MARK: - ToDoData Manager
class ToDoDataManager: ToDoDataObserver {
    
    private let realmManager: RealmManageable
    private var notificationToken: NotificationToken?
    var onDataChanged: (() -> Void)?
    
    init(realmManager: RealmManageable) {
        self.realmManager = realmManager
        setupObserver()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK: - Realm Noti
    private func setupObserver() {
            notificationToken = realmManager.observeChanges(for: ToDoItemRealm.self) { [weak self] changes in
                switch changes {
                case .initial, .update:
                    self?.onDataChanged?()
                case .error(let error):
                    print("Error observing Realm Changes: \(error)")
                }
            }
        }
}

//MARK: - ToDoDataFetchableProtocol
extension ToDoDataManager: ToDoDataFetchable {
    func getAllToDos() -> [ToDoItem] {
        let realmResults = realmManager.getSortedObjects(ToDoItemRealm.self, sortedByKeyPath: "date", ascending: true)
        
        return realmResults.map { $0.toToDoItem() }
    }
    
    func getToDos(forDate date: Date) -> [ToDoItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        let realmItems = realmManager.getFilteredObjects(ToDoItemRealm.self, predicate: predicate)
        
        return realmItems.map { $0.toToDoItem() }
    }
}

//MARK: - ToDoDataSearchableProtocol
extension ToDoDataManager: ToDoDataSearchable {
    func searchToDos(keyword: String) -> [ToDoItem] {
        let predicate = NSPredicate(format: "content CONTAINS[cd] %@", keyword)
        let realmItems = realmManager.getFilteredObjects(ToDoItemRealm.self, predicate: predicate)
        
        return realmItems.map { $0.toToDoItem() }
    }
}

//MARK: - ToDoDataEditableProtocol
extension ToDoDataManager: ToDoDataEditable {
    func createToDo(todoItem: ToDoItem) -> Result<Void, Error> {
        do {
            let realmItem = ToDoItemRealm(toDoItem: todoItem)
            try realmManager.add(realmItem, update: .modified)
            return .success(())
        } catch {
            return .failure(ToDoDataError.realmError(error))
        }
    }
    
    func updateToDo(id: UUID, content: String, image: UIImage?) -> Result<Void, Error> {
        do {
            guard let todoToUpdate = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
                return .failure(ToDoDataError.itemNotFound)
            }
            
            try realmManager.write {
                todoToUpdate.content = content
                
                if let newImage = image {
                    todoToUpdate.imageData = newImage.jpegData(compressionQuality: 0.7)
                } else {
                    todoToUpdate.imageData = nil
                }
                
                todoToUpdate.updatedAt = Date()
            }
            
            return .success(())
        } catch {
            return .failure(ToDoDataError.realmError(error))
        }
    }
    
    func toggleCompletion(id: UUID) -> Result<Void, Error> {
        do {
            guard let todoToUpdate = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
                return .failure(ToDoDataError.itemNotFound)
            }
            
            try realmManager.write {
                todoToUpdate.isCompleted = !todoToUpdate.isCompleted
                todoToUpdate.updatedAt = Date()
            }
            
            return .success(())
        } catch {
            return .failure(ToDoDataError.realmError(error))
        }
    }
}

//MARK: - ToDoDeletableProtocol
extension ToDoDataManager: ToDoDataDeletable {
    func deleteToDo(id: UUID) -> Result<Void, Error> {
        do {
            guard let todoToDelete = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
                return .failure(ToDoDataError.itemNotFound)
            }
            
            try realmManager.delete(todoToDelete)
            return .success(())
        } catch {
            return .failure(ToDoDataError.realmError(error))
        }
    }
    
    func deleteToDoAll() -> Result<Void, Error> {
        do {
            let todosToDelete = realmManager.getObjects(ToDoItemRealm.self)
            try realmManager.deleteAll(todosToDelete)
            return .success(())
        } catch {
            return .failure(ToDoDataError.realmError(error))
        }
    }
}
