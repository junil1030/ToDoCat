//
//  ToDoModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//

import UIKit

struct ToDoItem: Equatable {
    let id: UUID
    let content: String
    let image: UIImage?
    var isCompleted: Bool = false
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), content: String, image: UIImage? = nil, isCompleted: Bool = false, date: Date, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.content = content
        self.image = image
        self.isCompleted = isCompleted
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.content == rhs.content &&
        lhs.image?.jpegData(compressionQuality: 0.7) == rhs.image?.jpegData(compressionQuality: 0.7) &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.date == rhs.date &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }
}
