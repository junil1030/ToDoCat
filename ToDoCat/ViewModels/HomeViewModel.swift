//
//  HomeViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//
import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    
    //MARK: - Properties
    private var dataManager: ToDoDataFetchable & ToDoDataDeletable & ToDoDataObserver
    private var disposeBag = DisposeBag()
    
    //MARK: - Rx Streams
    // 입력
    let selectedDateTrigger = BehaviorRelay<Date>(value: Date())
    let loadDataTrigger = PublishRelay<Void>()
    let deleteItemTrigger = PublishRelay<UUID>()
    let selectItemTrigger = PublishRelay<IndexPath>()
    let addNewItemTrigger = PublishRelay<Void>()
    
    // 출력
    let allToDoItems = BehaviorRelay<[ToDoItem]>(value: [])
    let filteredToDoItems = BehaviorRelay<[ToDoItem]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let hasEvents = BehaviorRelay<[Date: Bool]>(value:[:])
    let error = PublishRelay<String>()
    let success = PublishRelay<String>()
    
    // 네비게이션
    let showDetailForNewItem = PublishRelay<Date>()
    let showDetailForExistingItem = PublishRelay<ToDoItem>()
    
    
//    //MARK: - Callbacks
    var navigateToDetailView: (() -> Void)?
    var cellToDetailView: ((ToDoItem) -> Void)?
    
    //MARK: - Initialization
    init(dataManager: ToDoDataFetchable & ToDoDataDeletable & ToDoDataObserver) {
        self.dataManager = dataManager
        setupBindings()
    }
    
    //MARK: - Private Methods
    private func setupBindings() {
        // 데이터 로드
        loadDataTrigger
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<[ToDoItem]> in
                guard let self = self else { return .just([]) }
                return self.fetchAllToDos()
            }
            .do(onNext: { [weak self] items in
                self?.allToDoItems.accept(items)
                self?.isLoading.accept(false)
                self?.updateHasEvents(items: items)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        // 날짜 선택 시 해당 날짜 항목 필터링
        selectedDateTrigger
            .distinctUntilChanged { Calendar.current.isDate($0, inSameDayAs: $1) }
            .flatMapLatest { [weak self] date -> Observable<[ToDoItem]> in
                guard let self = self else { return .just([]) }
                return self.fetchToDosforDate(date)
            }
            .bind(to: filteredToDoItems)
            .disposed(by: disposeBag)
        
        // 항목 삭제 처리
        deleteItemTrigger
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true)})
            .flatMapLatest { [weak self] id -> Observable<Result<Void, Error>> in
                guard let self = self else { return .just(.failure(NSError(domain: "ToDoCat", code: -1, userInfo: nil))) }
                return self.deleteToDo(id: id)
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    self?.loadDataTrigger.accept(())
                    self?.success.accept("삭제되었습니다.")
                case .failure(let error):
                    self?.error.accept("삭제에 실패했습니다: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
        
        // 선택 아이템 디테일 뷰로
        selectItemTrigger
            .withLatestFrom(filteredToDoItems) { indexPath, items -> ToDoItem? in
                guard indexPath.row < items.count else { return nil }
                return items[indexPath.row]
            }
            .compactMap { $0 }
            .bind(to: showDetailForExistingItem)
            .disposed(by: disposeBag)
        
        // 새 아이템 디테일 뷰로
        addNewItemTrigger
            .withLatestFrom(selectedDateTrigger)
            .bind(to: showDetailForNewItem)
            .disposed(by: disposeBag)
        
        setupDataManagerObserver()
    }
    
    private func setupDataManagerObserver() {
        // 데이터 변경 시 자동 갱신
        Observable<Void>.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.dataManager.onDataChanged = {
                observer.onNext(())
            }
            
            return Disposables.create {
                self.dataManager.onDataChanged = nil
            }
        }
        .subscribe(onNext: { [weak self] _ in
            self?.loadDataTrigger.accept(())
        })
        .disposed(by: disposeBag)
    }
    
    private func updateHasEvents(items: [ToDoItem]) {
        var eventsByDate: [Date: Bool] = [:]
        let calendar = Calendar.current
        
        for item in items {
            let dateKey = calendar.startOfDay(for: item.date)
            eventsByDate[dateKey] = true
        }
        
        hasEvents.accept(eventsByDate)
    }
    
    //MARK: - Data Fetching Methods
    private func fetchAllToDos() -> Observable<[ToDoItem]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.dataManager.getAllToDos { todos in
                observer.onNext(todos)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchToDosforDate(_ date: Date) -> Observable<[ToDoItem]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.dataManager.getToDos(forDate: date) { todos in
                observer.onNext(todos)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func deleteToDo(id: UUID) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.dataManager.deleteToDo(id: id) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: - Public Methods
    func checkHasEvent(for date: Date) -> Bool {
        let calendar = Calendar.current
        let datekey = calendar.startOfDay(for: date)
        return hasEvents.value[datekey] ?? false
    }
    
    func getSelectedDate() -> Date {
        return selectedDateTrigger.value
    }
}
