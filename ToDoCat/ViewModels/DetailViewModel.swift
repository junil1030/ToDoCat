//
//  DetailViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//
import UIKit

class DetailViewModel {
    
    enum Mode {
        case new
        case edit(ToDoItem)
    }
    
    private var mode: Mode
    var selectedDate: Date
    var currentToDoItem: ToDoItem?
    
    var onDataUpdated: (() -> Void)?
    var onDataAdded: (() -> Void)?
    
    var content: String
    var titleImage: UIImage?
    var addButtonText: String
    var createdTime: Date?
    var updatedTime: Date?
    
    init(mode: Mode, selectedDate: Date) {
        self.mode = mode
        self.selectedDate = selectedDate
        switch mode {
        case .new:
            self.content = "할 일을 입력해보세요 !!"
            self.titleImage = UIImage(systemName: "photo.badge.magnifyingglass")?.resized(to: CGSize(width: 40, height: 40))
            self.addButtonText = "추가하기"
            self.createdTime = nil
            self.updatedTime = nil
            
        case .edit(let todoItem):
            self.currentToDoItem = todoItem
            self.content = todoItem.content
            self.titleImage = todoItem.image
            self.addButtonText = "저장하기"
            self.createdTime = todoItem.createdAt
            self.updatedTime = todoItem.updatedAt
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onDataUpdated?()
        }
    }
    
    func getCurrentMode() -> Mode {
        return mode
    }
    
    // 새 항목 추가 메서드
    func createData(newToDo: ToDoItem) {
        if ToDoDataManager.shared.createToDo(todoItem: newToDo) {
            print("저장 완료")
            onDataAdded?()
        } else {
            fatalError("저장에 실패했습니다. 잠시 후 다시 시도해주세요.")
        }
    }
    
    func updateData(toDo: ToDoItem) {
        print(toDo.content)
        if ToDoDataManager.shared.updateToDo(id: toDo.id, content: toDo.content, image: toDo.image) {
            print("저장 완료")
            onDataAdded?()
        } else {
            fatalError("저장에 실패했습니다. 잠시 후 다시 시도해주세요.")
        }
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
