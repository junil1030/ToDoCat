//
//  DetailViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//
import UIKit

class DetailViewModel {
    
    
    // 새 항목 추가 메서드
    func addEntry(content: String, image: UIImage? = nil, isCompleted: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        let newToDo = ToDoItem(
            id: UUID()
            , content: content
            , image: image ?? createSampleImage(withColor: .systemBlue)
            , isCompleted: isCompleted
            , createdAt: createdAt
            , updatedAt: updatedAt)
        
    }
    
    // 샘플 이미지 생성 (실제 앱에서는 사용자가 제공하는 이미지 사용)
    private func createSampleImage(withColor color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 60, height: 60))
        }
    }
}
