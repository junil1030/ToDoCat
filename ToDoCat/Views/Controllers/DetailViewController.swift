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
            self.detailView.addButton.setTitle(detailViewModel.addButtonText, for: .normal)
            
            if let createdTime = detailViewModel.createdTime {
                self.detailView.createdTimeLabel.text = "생성된 날짜 \(createdTime.toString(format: "yyyy-MM-dd HH:mm"))"
            } else {
                self.detailView.createdTimeLabel.text = "생성된 날짜 \(Date().toString(format: "yyyy-MM-dd HH:mm"))"
            }
            
            if let updatedTime = detailViewModel.updatedTime {
                self.detailView.updatedTimeLabel.text = "최근 수정된 날짜 \(updatedTime.toString(format: "yyyy-MM-dd HH:mm"))"
            } else {
                self.detailView.updatedTimeLabel.text = ""
            }
            
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
        
        // 신규 생성일 때, 업데이트일 때 구분하는 코드 추가예정
        
        detailViewModel.updateData(newToDo: ToDoItem(
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
