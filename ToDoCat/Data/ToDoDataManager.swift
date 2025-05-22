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
    
    func performBackgroundTask<T>(_ task: @escaping () -> T, completion: @escaping (T) -> Void)
    func createThreadSafeReference<T: ThreadConfined>(for object: T) -> ThreadSafeReference<T>
    func resolve<T: ThreadConfined>(_ reference: ThreadSafeReference<T>) -> T?
}

// MARK: - Realm 구현
class RealmManager: RealmManageable {
    private let configuration: Realm.Configuration
    
    init(configuration: Realm.Configuration = Realm.Configuration(schemaVersion: 1)) throws {
        self.configuration = configuration
        print("Realm 위치: \(configuration.fileURL?.absoluteString ?? "Unknown")")
    }
    
    private func getRealm() -> Realm {
        do {
            return try Realm(configuration: configuration)
        } catch {
            fatalError("Realm 인스턴스 생성 실패: \(error)")
        }
    }
    
    func getObject<T: Object>(ofType type: T.Type, forPrimaryKey key: String) -> T? {
        return getRealm().object(ofType: type, forPrimaryKey: key)
    }
    
    func getObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return getRealm().objects(type)
    }
    
    func getFilteredObjects<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Results<T> {
        return getRealm().objects(type).filter(predicate)
    }
    
    func getSortedObjects<T: Object>(_ type: T.Type, sortedByKeyPath keyPath: String, ascending: Bool) -> Results<T> {
        return getRealm().objects(type).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    func write<T>(_ block: () throws -> T) throws -> T {
        let realm = getRealm()
        return try realm.write(block)
    }
    
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) throws {
        let realm = getRealm()
        try realm.write {
            realm.add(object, update: update)
        }
    }
    
    func delete<T: Object>(_ object: T) throws {
        let realm = getRealm()
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll<T: Object>(_ objects: Results<T>) throws {
        let realm = getRealm()
        try realm.write {
            realm.delete(objects)
        }
    }
    
    func observeChanges<T: Object>(for type: T.Type, completion: @escaping (RealmCollectionChange<Results<T>>) -> Void) -> NotificationToken {
        let results = getRealm().objects(type)
        return results.observe(completion)
    }
    
    // 백그라운드 작업을 위한 메서드
    func performBackgroundTask<T>(_ task: @escaping () -> T, completion: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                let result = task()
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func createThreadSafeReference<T: ThreadConfined>(for object: T) -> ThreadSafeReference<T> {
        return ThreadSafeReference(to: object)
    }
    
    func resolve<T: ThreadConfined>(_ reference: ThreadSafeReference<T>) -> T? {
        let realm = getRealm()
        return realm.resolve(reference)
    }
}

//MARK: - ToDoData Protocol
protocol ToDoDataFetchable {
    func getAllToDos(completion: @escaping ([ToDoItem]) -> Void)
    func getToDos(forDate date: Date, completion: @escaping ([ToDoItem]) -> Void)
}

protocol ToDoDataSearchable {
    func searchToDos(keyword: String, completion: @escaping ([ToDoItem]) -> Void)
}

protocol ToDoDataEditable {
    func createToDo(todoItem: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func updateToDo(id: UUID, content: String, image: UIImage?, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleCompletion(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol ToDoDataDeletable {
    func deleteToDo(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteToDoAll(completion: @escaping (Result<Void, Error>) -> Void)
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
    func getAllToDos(completion: @escaping ([ToDoItem]) -> Void) {
        realmManager.performBackgroundTask {
            let realmResults = self.realmManager.getSortedObjects(ToDoItemRealm.self, sortedByKeyPath: "date", ascending: true)
            return realmResults.map { $0.toToDoItem() }
        } completion: { todoItems in
            completion(todoItems)
        }
    }
    
    func getToDos(forDate date: Date, completion: @escaping ([ToDoItem]) -> Void) {
        realmManager.performBackgroundTask {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
            let realmItems = self.realmManager.getFilteredObjects(ToDoItemRealm.self, predicate: predicate)
            let todoItems = realmItems.map { $0.toToDoItem() }
            
            // 완료되지 않은 아이템 먼저 앞으로 빼고, 생성 시간 오름차순
            let sortedItems = todoItems.sorted { (first, second) -> Bool in
                if first.isCompleted == second.isCompleted {
                    // 둘다 완료 상태면 생성 시간으로 오름차순 정렬
                    return first.createdAt < second.createdAt
                } else {
                    // 완료 안된 항목이 완료된 항목보다 앞에 오도록
                    return !first.isCompleted && second.isCompleted
                }
            }
            
            return sortedItems
        } completion: { todoItems in
            completion(todoItems)
        }
    }
}

//MARK: - ToDoDataSearchableProtocol
extension ToDoDataManager: ToDoDataSearchable {
    func searchToDos(keyword: String, completion: @escaping ([ToDoItem]) -> Void) {
        realmManager.performBackgroundTask {
            let predicate = NSPredicate(format: "content CONTAINS[cd] %@", keyword)
            let realmItems = self.realmManager.getFilteredObjects(ToDoItemRealm.self, predicate: predicate)
            
            return realmItems.map { $0.toToDoItem() }
        } completion: { todoItems in
            completion(todoItems)
        }
    }
}

//MARK: - ToDoDataEditableProtocol
extension ToDoDataManager: ToDoDataEditable {
    func createToDo(todoItem: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        realmManager.performBackgroundTask {
            do {
                let realmItem = ToDoItemRealm(toDoItem: todoItem)
                try self.realmManager.add(realmItem, update: .modified)
                return Result<Void, Error>.success(())
            } catch {
                return Result<Void, Error>.failure(ToDoDataError.realmError(error))
            }
        } completion: { result in
            completion(result)
        }
    }
    
    func updateToDo(id: UUID, content: String, image: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let todoToUpdate = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
            completion(.failure(ToDoDataError.itemNotFound))
            return
        }
        
        let reference = realmManager.createThreadSafeReference(for: todoToUpdate)
        let imageData = image?.jpegData(compressionQuality: 0.7)
        
        realmManager.performBackgroundTask {
            guard let todoItem = self.realmManager.resolve(reference) else {
                return Result<Void, Error>.failure(ToDoDataError.itemNotFound)
            }
            
            do {
                try self.realmManager.write {
                    todoItem.content = content
                    todoItem.imageData = imageData
                    todoItem.updatedAt = Date()
                }
                return Result<Void, Error>.success(())
            } catch {
                return Result<Void, Error>.failure(ToDoDataError.realmError(error))
            }
        } completion: { result in
            completion(result)
        }
    }
    
    func toggleCompletion(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let todoToUpdate = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
            completion(.failure(ToDoDataError.itemNotFound))
            return
        }
        
        let reference = realmManager.createThreadSafeReference(for: todoToUpdate)
        let currentCompletionState = todoToUpdate.isCompleted
        
        realmManager.performBackgroundTask {
            guard let todoItem = self.realmManager.resolve(reference) else {
                return Result<Void, Error>.failure(ToDoDataError.itemNotFound)
            }
            
            do {
                try self.realmManager.write {
                    todoItem.isCompleted = !currentCompletionState
                    todoItem.updatedAt = Date()
                }
                return Result<Void, Error>.success(())
            } catch {
                return Result<Void, Error>.failure(ToDoDataError.realmError(error))
            }
        } completion: { result in
            completion(result)
        }
    }}

//MARK: - ToDoDeletableProtocol
extension ToDoDataManager: ToDoDataDeletable {
    func deleteToDo(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let todoToDelete = realmManager.getObject(ofType: ToDoItemRealm.self, forPrimaryKey: id.uuidString) else {
            completion(.failure(ToDoDataError.itemNotFound))
            return
        }
        
        let reference = realmManager.createThreadSafeReference(for: todoToDelete)
        
        realmManager.performBackgroundTask {
            guard let todoItem = self.realmManager.resolve(reference) else {
                return Result<Void, Error>.failure(ToDoDataError.itemNotFound)
            }
            
            do {
                try self.realmManager.delete(todoItem)
                return Result<Void, Error>.success(())
            } catch {
                return Result<Void, Error>.failure(ToDoDataError.realmError(error))
            }
        } completion: { result in
            completion(result)
        }
    }
    
    func deleteToDoAll(completion: @escaping (Result<Void, Error>) -> Void) {
        realmManager.performBackgroundTask {
            do {
                let todosToDelete = self.realmManager.getObjects(ToDoItemRealm.self)
                try self.realmManager.deleteAll(todosToDelete)
                return Result<Void, Error>.success(())
            } catch {
                return Result<Void, Error>.failure(ToDoDataError.realmError(error))
            }
        } completion: { result in
            completion(result)
        }
    }
}
