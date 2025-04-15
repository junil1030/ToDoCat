//
//  DetailViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/16/25.
//
import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    
    //MARK: - Types
    enum Mode {
        case new
        case edit(ToDoItem)
    }
    
    //MARK: - Properties
    private let dataManager: ToDoDataEditable
    private let imageService: ImageServiceProtocol
    private let disposeBag = DisposeBag()
    
    private var mode: Mode
    var selectedDate: Date
    var currentToDoItem: ToDoItem?
    
    // placeholer 상수
    let placeholderText = "할 일을 입력해보세요 !!"
    
    //MARK: - Rx Streams
    // 입력 이벤트
    let contentText = BehaviorRelay<String>(value: "")
    let imageRequest = PublishRelay<String>()
    let saveTriggered = PublishRelay<Void>()
    let cancelTriggered = PublishRelay<Void>()
    
    // UI 상태
    let titleImage = BehaviorRelay<UIImage?>(value: nil)
    let addButtonText = BehaviorRelay<String>(value: "")
    let createdTimeText = BehaviorRelay<String?>(value: nil)
    let updatedTimeText = BehaviorRelay<String?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    // 출력 이벤트
    let errorMessage = PublishRelay<String>()
    let successMessage = PublishRelay<String>()
    
    var onDismiss: (() -> Void)?
    
    
    //MARK: - Initialization
    init(mode: Mode,
         selectedDate: Date,
         dataManager: ToDoDataEditable,
         imageService: ImageServiceProtocol = ImageService()) {
        self.mode = mode
        self.selectedDate = selectedDate
        self.dataManager = dataManager
        self.imageService = imageService
        
        setupInitialState(mode: mode)
        setupBindings()
    }
    
    //MARK: - Private Methods
    private func setupInitialState(mode: Mode) {
        switch mode {
        case .new:
            contentText.accept(placeholderText)
            titleImage.accept(UIImage(named: "DefaultImage"))
            addButtonText.accept("추가하기")
            let nowString = Date().toString(format: "yyyy-MM-dd HH:mm")
            createdTimeText.accept("생성된 날짜 \(nowString)")
            updatedTimeText.accept("")
            
        case .edit(let todoItem):
            self.currentToDoItem = todoItem
            contentText.accept(todoItem.content)
            titleImage.accept(todoItem.image)
            addButtonText.accept("저장하기")
            createdTimeText.accept("생성된 날짜 \(todoItem.createdAt.toString(format: "yyyy-MM-dd HH:mm"))")
            updatedTimeText.accept("최근 수정된 날짜 \(todoItem.updatedAt.toString(format: "yyyy-MM-dd HH:mm"))")
        }
    }
    
    private func setupBindings() {
        // 이미지 요청
        imageRequest
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [weak self] url -> Observable<UIImage?> in
                guard let self = self else { return .just(nil) }
                return self.loadImage(from: url)
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .subscribe(onNext: { [weak self] image in
                if let image = image {
                    self?.titleImage.accept(image)
                } else {
                    self?.errorMessage.accept("이미지를 불러올 수 없습니다.")
                }
            })
            .disposed(by: disposeBag)
        
        saveTriggered
            .withLatestFrom(contentText)
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [weak self] content -> Observable<Result<Void, Error>> in
                guard let self = self else { return .just(.failure(NSError(domain: "ToDoCat", code: -1, userInfo: nil))) }
                
                switch self.mode {
                case .new:
                    return self.createToDoItem(content: content)
                case .edit:
                    return self.updateToDoItem(content: content)
                }
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    self?.onDismiss?()
                case .failure(let error):
                    self?.errorMessage.accept("저장에 실패했습니다: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func loadImage(from url: String) -> Observable<UIImage?> {
        return imageService.getImage(from: url)
            .asObservable()
            .map { image -> UIImage in
                return image
            }
            .catch { error -> Observable<UIImage?> in
                print("Image 로딩 에러: \(error)")
                return .just(UIImage(named: "DefaultImage"))
            }
    }
    
    // 매개변수 입력안하고 바인딩 걸어서 가져오게끔 하고싶은디
    private func createToDoItem(content: String) -> Observable<Result<Void,Error>> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(.failure(NSError(domain: "ToDoCat", code: -1, userInfo: nil)))
                observer.onCompleted()
                return Disposables.create()
            }
            
            let newToDo = ToDoItem(
                id: UUID(),
                content: content,
                image: self.titleImage.value ?? UIImage(named: "DefaultImage")!,
                isCompleted: false,
                date: self.selectedDate,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            self.dataManager.createToDo(todoItem: newToDo) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func updateToDoItem(content: String) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            guard let self = self, let todoItem = self.currentToDoItem else {
                observer.onNext(.failure(NSError(domain: "ToDoCat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing todo item"])))
                observer.onCompleted()
                return Disposables.create()
            }
            
            let updatedImage = self.titleImage.value ?? UIImage(named: "DefaultImage")
            
            self.dataManager.updateToDo(id: todoItem.id, content: content, image: updatedImage) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Public Methods
    func getCurrentMode() -> Mode {
        return mode
    }
    
    func setDefaultImage() {
        titleImage.accept(UIImage(named: "DefaultImage"))
    }
    
    func setCustomImage(_ image: UIImage) {
        titleImage.accept(image)
    }
    
    func requestCatImage(says: String? = nil) {
        let url = Constants.getCatImageUrl(says: says)
        imageRequest.accept(url)
    }
}
