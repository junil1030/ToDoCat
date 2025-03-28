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
    private let imageService: ImageServiceProtocol
    var selectedDate: Date
    var currentToDoItem: ToDoItem?
    
    var onImageChanged: ((UIImage?) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onDataAdded: (() -> Void)?
    
    var content: String
    var titleImage: UIImage? {
        didSet {
            onImageChanged?(titleImage)
        }
    }
    var addButtonText: String
    var createdTime: Date?
    var updatedTime: Date?
    
    let placeholderText = "할 일을 입력해보세요 !!"
    
    init(mode: Mode, selectedDate: Date, imageService: ImageServiceProtocol = ImageService()) {
        self.mode = mode
        self.selectedDate = selectedDate
        switch mode {
        case .new:
            self.content = placeholderText
            self.titleImage = UIImage(named: "DefaultImage")
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
        
        self.imageService = imageService
        
        DispatchQueue.main.async { [weak self] in
            self?.onDataUpdated?()
            self?.onImageChanged?(self?.titleImage)
        }
    }
    
    func getCurrentMode() -> Mode {
        return mode
    }
    
    // 새 항목 추가 메서드
    func createData(content: String) {
        let newToDo = ToDoItem(
            id: UUID(),
            content: content,
            image: titleImage!,
            isCompleted: false,
            date: selectedDate,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        if ToDoDataManager.shared.createToDo(todoItem: newToDo) {
            print("저장 완료")
            onDataAdded?()
        } else {
            fatalError("저장에 실패했습니다. 잠시 후 다시 시도해주세요.")
        }
    }
    
    func updateData(content: String) {
        guard var toDoItem = currentToDoItem else {
            print("저장할 데이터가 존재하지 않습니다.")
            return
        }
        
        toDoItem.content = content
        toDoItem.image = titleImage
        toDoItem.updatedAt = Date()
        
        if ToDoDataManager.shared.updateToDo(id: toDoItem.id, content: toDoItem.content, image: toDoItem.image) {
            print("저장 완료")
            onDataAdded?()
        } else {
            fatalError("저장에 실패했습니다. 잠시 후 다시 시도해주세요.")
        }
    }
    
    func addImage(imageUrl: String, completion: @escaping (Bool) -> Void) {
        imageService.getImage(from: imageUrl) { [weak self] result in
            switch result {
            case .success(let image):
                self?.titleImage = image
                completion(true)
            case .failure(let error):
                print("이미지 로드 실패: \(error)")
                completion(false)
            }
        }
    }
}
