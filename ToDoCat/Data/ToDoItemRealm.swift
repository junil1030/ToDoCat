//
//  ToDoItemRealm.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//

import UIKit
import RealmSwift

//MARK: - ToDoItem Realm Class
class ToDoItemRealm: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var content: String
    @Persisted var imageData: Data?
    @Persisted var isCompleted: Bool = false
    @Persisted var createdAt: Date
    @Persisted var updatedAt: Date
    
    override init() {
        super.init()
    }
    
    convenience init(toDoItem: ToDoItem) {
        self.init()
        self.id = toDoItem.id.uuidString
        self.content = toDoItem.content
        if let image = toDoItem.image {
            self.imageData = image.jpegData(compressionQuality: 0.7)
        }
        self.isCompleted = toDoItem.isCompleted
        self.createdAt = toDoItem.createdAt
        self.updatedAt = toDoItem.updatedAt
    }
    
    func toToDoItem() -> ToDoItem {
        let image = imageData != nil ? UIImage(data: imageData!) : nil
        return ToDoItem(id: UUID(uuidString: id) ?? UUID(), content: content, image: image, isCompleted: isCompleted, createdAt: createdAt, updatedAt: updatedAt)
    }
}
