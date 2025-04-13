//
//  SearchViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//
import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    //MARK: - Properties
    private let dataManager: ToDoDataSearchable
    private let disposeBag = DisposeBag()
    //private var isSearching = false
    
    //MARK: - Rx Streams
    // 검색어 입력
    let searchText = BehaviorRelay<String>(value: "")
    
    // 검색 결과
    let searchResults = BehaviorRelay<[ToDoItem]>(value: [])
    
    // 검색 중
    let isSearching = BehaviorRelay<Bool>(value: false)
    
    // 선택 아이템
    let selectedItem = PublishRelay<ToDoItem>()
    
    // 에러
    let error = PublishRelay<String>()
    
    // 화면 이동 클로저
    var cellToDetailView: ((ToDoItem) -> Void)?
    
    //MARK: - Initaliztion
    init(dataManager: ToDoDataSearchable) {
        self.dataManager = dataManager
        setupBindings()
    }
    
    //MARK: - Private Methods
    private func setupBindings() {
        
        searchText
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .do(onNext: { [weak self] _ in self?.isSearching.accept(true) })
            .flatMapLatest { [weak self] keyword -> Observable<[ToDoItem]> in
                guard let self = self else { return .just([]) }
                return self.performSearch(keyword: keyword)
            }
            .do(onNext: { [weak self] _ in self?.isSearching.accept(false) })
            .bind(to: searchResults)
            .disposed(by: disposeBag)
    }
    
    private func performSearch(keyword: String) -> Observable<[ToDoItem]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 검색어가 비어있으면 빈 결과 반환
            if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.dataManager.searchToDos(keyword: keyword) { results in
                observer.onNext(results)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: - Public Methods
    // 테이블 뷰 선택
    func selectItem(at indexPath: IndexPath) {
        let items = self.searchResults.value
        guard indexPath.row < items.count else { return }
        
        let selectedToDo = items[indexPath.row]
        selectedItem.accept(selectedToDo)
    }
    
    // 검색어 초기화
    func clearSearch() {
        searchText.accept("")
        searchResults.accept([])
    }
}
