//
//  DetailViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    private let detailView = DetailView()
    private let detailViewModel: DetailViewModel
    
    init(mode: DetailViewModel.Mode, selectedDate: Date) {
        self.detailViewModel = DetailViewModel(mode: mode, selectedDate: selectedDate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        setupActions()
    }
    
    private func setupBindings() {
        detailViewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.detailView.contentText.text = detailViewModel.content
            self.detailView.titleImage.image = detailViewModel.titleImage
            self.detailView.timeLabel.text = detailViewModel.selectedDate.toKST().toString()
        }
        
        detailViewModel.onDataAdded = { [weak self] in
            // 토스트 메세지 띄워보는 거?
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupActions() {
        detailView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        detailView.getCatButton.addTarget(self, action: #selector(getCatButtonTapped), for: .touchUpInside)
        detailView.getDogButton.addTarget(self, action: #selector(getDogButtonTapped), for: .touchUpInside)
        detailView.getCustomImageButton.addTarget(self, action: #selector(getCustomImageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        detailViewModel.addEntry(newToDo: ToDoItem(
            id: UUID()
            , content: detailView.contentText.text!
            , image: detailView.titleImage.image ?? nil
            , isCompleted: false
            , date: detailViewModel.selectedDate
            , createdAt: Date()
            , updatedAt: Date())
        )
    }
    
    @objc private func getCatButtonTapped() {
        print("고양이 버튼 눌림")
    }
    
    @objc private func getDogButtonTapped() {
        print("강아지 버튼 눌림")
    }
    
    @objc private func getCustomImageButtonTapped() {
        print("커스텀 이미지 버튼 눌림")
    }
}
