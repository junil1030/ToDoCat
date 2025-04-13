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
        
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchViewModel.clearSearch()
    }
    
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
        
        searchViewModel.selectedItem
            .subscribe(onNext: { [weak self] todoItem in
                self?.searchViewModel.cellToDetailView?(todoItem)
            })
            .disposed(by: disposeBag)
    }
}
