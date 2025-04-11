//
//  DetailViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//
import Foundation
import RxSwift

class DetailViewModel {
    
    enum Mode {
        case new
        case edit(ToDoItem)
    }
    
    private var mode: Mode
    private let dataManager: ToDoDataEditable
    private let imageService: ImageServiceProtocol
    var selectedDate: Date
    var currentToDoItem: ToDoItem?
    
    var onImageChanged: ((UIImage?) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onDataAdded: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onError: ((String) -> Void)?
    
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
    
    init(mode: Mode,
         selectedDate: Date,
         dataManager: ToDoDataEditable,
         imageService: ImageServiceProtocol = ImageService()) {
        self.mode = mode
        self.selectedDate = selectedDate
        self.dataManager = dataManager
        self.imageService = imageService
        
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
            image: titleImage ?? UIImage(named: "DefaultImage")!,
            isCompleted: false,
            date: selectedDate,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        dataManager.createToDo(todoItem: newToDo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("저장 완료")
                    self?.onDataAdded?()
                case .failure(let error):
                    print("저장에 실패했습니다. 에러: \(error)")
                    self?.onError?("저장에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    func updateData(content: String) {
        guard let toDoItem = currentToDoItem else {
            print("저장할 데이터가 존재하지 않습니다.")
            onError?("저장할 데이터가 존재하지 않습니다.")
            return
        }
        
        // 업데이트할 이미지를 안전하게 처리
        let updatedImage = titleImage ?? UIImage(named: "DefaultImage")
        
        dataManager.updateToDo(id: toDoItem.id, content: content, image: updatedImage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("업데이트 완료")
                    self?.onDataAdded?()
                case .failure(let error):
                    print("업데이트에 실패했습니다. 에러: \(error)")
                    self?.onError?("업데이트에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    func addImage(imageUrl: String, completion: @escaping (Bool) -> Void) {
        imageService.getImage(from: imageUrl) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.titleImage = image
                    completion(true)
                case .failure(let error):
                    print("이미지 로드 실패: \(error)")
                    self?.onError?("이미지를 불러올 수 없습니다. 다른 이미지를 시도해보세요.")
                    completion(false)
                }
            }
        }
    }
}

extension DetailViewModel {
    
    func rx_addImage(imageUrl: String) -> Single<Bool> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.success(false))
                return Disposables.create()
            }
            
            self.addImage(imageUrl: imageUrl) { success in
                single(.success(success))
            }
            
            return Disposables.create()
        }
    }
}
