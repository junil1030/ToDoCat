//
//  DetailViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//
import UIKit
import PhotosUI

class DetailViewController: UIViewController {
    
    private let detailView: DetailView
    private var detailViewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.detailViewModel = viewModel
        self.detailView = DetailView()
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
        
        detailView.contentText.delegate = self
        
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
            self?.detailViewModel.onDismiss?()
        }
        
        detailViewModel.onImageChanged = { [weak self] image in
            DispatchQueue.main.async {
                self?.detailView.updateImage(image: image)
            }
        }
    }
    
    private func setupActions() {
        detailView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        detailView.getCatButton.addTarget(self, action: #selector(getCatButtonTapped), for: .touchUpInside)
        detailView.getDefaultImageButton.addTarget(self, action: #selector(getDefaultImageButtonTapped), for: .touchUpInside)
        detailView.getCustomImageButton.addTarget(self, action: #selector(getCustomImageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        let currentMode = detailViewModel.getCurrentMode()
        
        let content = detailView.contentText.text ?? ""
        
        switch currentMode {
        case .new:
            detailViewModel.createData(content: content)
        case .edit:
            detailViewModel.updateData(content: content)
        }
    }
    
    @objc private func getCatButtonTapped() {
        self.view.makeToastActivity(.center)
        
        detailViewModel.addImage(imageUrl: Constants.getCatImageUrl(says: nil)) { [weak self] success in
            DispatchQueue.main.async {
                self?.view.hideToastActivity()
                if !success {
                    self?.showToast(message: "이미지를 불러오지 못했습니다.")
                }
            }
        }
    }
    
    @objc private func getDefaultImageButtonTapped() {
        detailViewModel.titleImage = UIImage(named: "DefaultImage")
    }
    
    @objc private func getCustomImageButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func showToast(message: String) {
        self.view.makeToast("\(message)", duration: 2.0, position: .bottom)
    }
}

//MARK: - UITextViewDelegate
extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == detailViewModel.placeholderText {
            textView.text = ""
            textView.textColor = UIColor(named: "TextColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = detailViewModel.placeholderText
            textView.textColor = .lightGray
        }
    }
}

//MARK: - HeadingPHPickerViewControllerDelegate
extension DetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let selectImage = image as? UIImage {
                    self.detailViewModel.titleImage = selectImage
                }
            }
        }
    }
}

