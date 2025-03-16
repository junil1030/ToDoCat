//
//  DetailViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//
import UIKit

class DetailViewModel {
    let currentTime: String
    let content: String
    let image: UIImage?
    
    init(currentTime: String, content: String, image: UIImage?) {
        self.currentTime = currentTime
        self.content = content
        self.image = image
    }
    
    private func saveData() {
        
    }
    
}
