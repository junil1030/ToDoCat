//
//  ToDoModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//

import UIKit

struct ToDoModel {
    let id: UUID
    let date: Date
    let content: String
    let image: UIImage?
    
    init(id: UUID = UUID(), date: Date, content: String, image: UIImage? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.image = image
    }
}
