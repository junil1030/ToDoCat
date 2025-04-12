//
//  SearchViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    private let searchView: SearchView
    private var searchViewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    //var searchTimer: Timer?
    
    init(viewModel: SearchViewModel) {
        self.searchViewModel = viewModel
        self.searchView = SearchView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupDelegates()
        setupBindings()
    }
    
//    deinit {
//        searchTimer?.invalidate()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchViewModel.clearSearch()
//        searchView.searchBar.text = ""
//        searchViewModel.searchResult.removeAll()
//        searchViewModel.currentToDoItem = nil
//        searchView.tableView.reloadData()
    }
    
//    private func setupDelegates() {
//        searchView.searchBar.delegate = self
//        
//        searchView.tableView.delegate = self
//        searchView.tableView.dataSource = self
    //    }
    
    private func setupBindings() {
        // 검색창 바인딩
        searchView.searchBar.rx.text.orEmpty
            .bind(to: searchViewModel.searchText)
            .disposed(by: disposeBag)
        
        // 검색 결과를 테이블 뷰에 바인딩
        searchViewModel.searchResults
            .bind(to: searchView.tableView.rx.items(cellIdentifier: ToDoTableViewCell.identifier,
                                                    cellType: ToDoTableViewCell.self))
        { row, item, cell in
            cell.configure(with: item)
            cell.accessoryType = .disclosureIndicator
        }
        .disposed(by: disposeBag)
        
        // 셀 선택 바인딩
        searchView.tableView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.searchView.tableView.deselectRow(at: indexPath, animated: true)
            })
            .subscribe(onNext: { [weak self] indexPath in
                self?.searchViewModel.selectItem(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        searchViewModel.isSearching
            .subscribe(onNext: { [weak self] isSearching in
                if isSearching {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
                }
            })
            .disposed(by: disposeBag)
        
        // 선택된 아이템 처리 (이전의 cellToDetailView 대체)
        // 여기서는 코디네이터 패턴을 가정하고, 해당 코디네이터로 이벤트 전달
        searchViewModel.selectedItem
            .subscribe(onNext: { [weak self] todoItem in
                // 예: self?.coordinator.showDetail(for: todoItem)
                // 또는 임시 구현:
                self?.searchViewModel.cellToDetailView?(todoItem)
            })
            .disposed(by: disposeBag)
        //        searchViewModel.onDataChanged = { [weak self] in
        //            self?.searchView.tableView.reloadData()
        //        }
    }
}

//extension SearchViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let keyword = searchBar.text else { return }
//        searchViewModel.search(keyword: keyword)
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchTimer?.invalidate()
//        
//        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
//            guard let self = self else { return }
//            self.searchViewModel.search(keyword: searchText)
//        }
//    }
//}
//
//extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchViewModel.searchResult.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: ToDoTableViewCell.identifier,
//            for: indexPath
//        ) as? ToDoTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        let entry = searchViewModel.searchResult[indexPath.row]
//        cell.configure(with: entry)
//        cell.accessoryType = .disclosureIndicator
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        self.searchViewModel.toDoCellTapped(index: indexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 84
//    }
//}
