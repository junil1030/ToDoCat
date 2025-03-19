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
    @Persisted var date: Date
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
        self.date = toDoItem.date
        self.createdAt = toDoItem.createdAt
        self.updatedAt = toDoItem.updatedAt
    }
    
    func toToDoItem() -> ToDoItem {
        let image = imageData != nil ? UIImage(data: imageData!) : nil
        
//        let timezone = Common.korTimeZone
//        let createdAtKST = Calendar.current.date(byAdding: .second
//                                                 ,value: timezone.secondsFromGMT(for: createdAt)
//                                                 ,to: createdAt)!
//        let updatedAtKST = Calendar.current.date(byAdding: .second
//                                                 ,value: timezone.secondsFromGMT(for: updatedAt)
//                                                 ,to: updatedAt)!
//        let dateAtKST = Calendar.current.date(byAdding: .second
//                                              ,value: timezone.secondsFromGMT(for: date)
//                                              ,to: date)!
        
        return ToDoItem(id: UUID(uuidString: id) ?? UUID()
                        , content: content
                        , image: image
                        , isCompleted: isCompleted
                        , date: date
                        , createdAt: createdAt
                        , updatedAt: updatedAt
        )
    }
}
