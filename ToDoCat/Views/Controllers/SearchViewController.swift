//
//  SearchViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/20/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let searchView = SearchView()
    private let searchViewModel = SearchViewModel()
    
    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupDelegates()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchView.searchBar.text = ""
        searchViewModel.searchResult.removeAll()
        searchViewModel.currentToDoItem = nil
        searchView.tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        
    }
    
    private func setupDelegates() {
        searchView.searchBar.delegate = self
        
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
    }
    
    private func setupBindings() {
        searchViewModel.onDataChanged = { [weak self] in
            self?.searchView.tableView.reloadData()
        }
        
        searchViewModel.cellToDetailView = { [weak self] toDoItem in
            self?.showDetailView(mode: .edit(toDoItem))
        }
        
    }
    
    private func showDetailView(mode: DetailViewModel.Mode) {
        guard let selectedDate = searchViewModel.currentToDoItem?.date else { return }
        let detailViewController = DetailViewController(
            mode: mode,
            selectedDate: selectedDate
        )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        searchViewModel.search(keyword: keyword)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let entry = searchViewModel.searchResult[indexPath.row]
        cell.configure(with: entry)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.searchViewModel.toDoCellTapped(index: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}
