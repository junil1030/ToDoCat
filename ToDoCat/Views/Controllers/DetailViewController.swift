//
//  DetailViewController.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//
import UIKit
import Toast_Swift
import PhotosUI
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
    private let detailView: DetailView
    private var detailViewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
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
        
        setupDelegates()
        setupBindings()
        setupActions()
        updateTextViewColor()
    }
    
    private func setupDelegates() {
        detailView.contentText.delegate = self
    }
    
    private func setupBindings() {
        // 컨텐츠 텍스트
        detailViewModel.contentText
            .bind(to: detailView.contentText.rx.text)
            .disposed(by: disposeBag)
        
        // 이미지
        detailViewModel.titleImage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.detailView.updateImage(image: image)
            })
            .disposed(by: disposeBag)
        
        // 버튼 텍스트
        detailViewModel.addButtonText
            .bind(to: detailView.addButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        // 시간
        detailViewModel.createdTimeText
            .bind(to: detailView.createdTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        detailViewModel.updatedTimeText
            .bind(to: detailView.updatedTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 로딩 상태
        detailViewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 메세지
        detailViewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
            
        // 화면 닫기
//        detailViewModel.onDataUpdated = { [weak self] in
//            guard let self = self else { return }
//            self.detailView.contentText.text = detailViewModel.content
//            self.detailView.titleImage.image = detailViewModel.titleImage
//            self.detailView.addButton.setTitle(detailViewModel.addButtonText, for: .normal)
//            
//            if let createdTime = detailViewModel.createdTime {
//                self.detailView.createdTimeLabel.text = "생성된 날짜 \(createdTime.toString(format: "yyyy-MM-dd HH:mm"))"
//            } else {
//                self.detailView.createdTimeLabel.text = "생성된 날짜 \(Date().toString(format: "yyyy-MM-dd HH:mm"))"
//            }
//            
//            if let updatedTime = detailViewModel.updatedTime {
//                self.detailView.updatedTimeLabel.text = "최근 수정된 날짜 \(updatedTime.toString(format: "yyyy-MM-dd HH:mm"))"
//            } else {
//                self.detailView.updatedTimeLabel.text = ""
//            }
//            
//        }
//        
//        detailViewModel.onDataAdded = { [weak self] in
//            self?.detailViewModel.onDismiss?()
//        }
//        
//        detailViewModel.onImageChanged = { [weak self] image in
//            DispatchQueue.main.async {
//                self?.detailView.updateImage(image: image)
//            }
//        }
//        
//        detailViewModel.onError = { [weak self] error in
//            self?.view.makeToast(error)
//        }
    }
    
    private func setupActions() {
        // 추가, 저장 버튼
        detailView.addButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                guard let currentText = self.detailView.contentText.text,
                !currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                currentText != self.detailViewModel.placeholderText else {
                    self.detailView.makeToast("내용을 입력해주세요.")
                    return
                }
                self.detailViewModel.contentText.accept(currentText)
                
                self.detailViewModel.saveTriggered.accept(())
            })
            .disposed(by: disposeBag)
        
        // 고양이 이미지
        detailView.getCatButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.detailViewModel.requestCatImage()
            })
            .disposed(by: disposeBag)
        
        // 기본 이미지
        detailView.getDefaultImageButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.detailViewModel.setDefaultImage()
            })
            .disposed(by: disposeBag)
        
        // 커스텀 이미지
        detailView.getCustomImageButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showImagePicker()
            })
            .disposed(by: disposeBag)
//        detailView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//        detailView.getCatButton.addTarget(self, action: #selector(getCatButtonTapped), for: .touchUpInside)
//        detailView.getDefaultImageButton.addTarget(self, action: #selector(getDefaultImageButtonTapped), for: .touchUpInside)
//        detailView.getCustomImageButton.addTarget(self, action: #selector(getCustomImageButtonTapped), for: .touchUpInside)
    }
    
    private func updateTextViewColor() {
        if detailView.contentText.text == detailViewModel.placeholderText ||
           detailView.contentText.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            detailView.contentText.textColor = .lightGray
        } else {
            detailView.contentText.textColor = UIColor(named: "TextColor") ?? .black
        }
    }
    
    private func showImagePicker() {
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
    
//    @objc private func addButtonTapped() {
//        let currentMode = detailViewModel.getCurrentMode()
//        
//        let content = detailView.contentText.text ?? ""
//        
//        switch currentMode {
//        case .new:
//            detailViewModel.createData(content: content)
//        case .edit:
//            detailViewModel.updateData(content: content)
//        }
//    }
//    
//    @objc private func getCatButtonTapped() {
//        self.view.makeToastActivity(.center)
//        
//        detailViewModel.addImage(imageUrl: Constants.getCatImageUrl(says: nil)) { [weak self] success in
//            DispatchQueue.main.async {
//                self?.view.hideToastActivity()
//                if !success {
//                    self?.showToast(message: "이미지를 불러오지 못했습니다.")
//                }
//            }
//        }
//    }
//    
//    @objc private func getDefaultImageButtonTapped() {
//        detailViewModel.titleImage = UIImage(named: "DefaultImage")
//    }
//    
//    @objc private func getCustomImageButtonTapped() {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = .images
//        
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//
}

//MARK: - UITextViewDelegate
extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == detailViewModel.placeholderText {
            textView.text = ""
            textView.textColor = UIColor(named: "TextColor") ?? .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = detailViewModel.placeholderText
            textView.textColor = .lightGray
        } else {
            textView.textColor = UIColor(named: "TextColor") ?? .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.textColor = .lightGray
        } else {
            textView.textColor = UIColor(named: "TextColor") ?? .black
        }
    }
}

//MARK: - HeadingPHPickerViewControllerDelegate
extension DetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                if let selectImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.detailViewModel.setCustomImage(selectImage)
                    }
                }
            }
        }
    }

}

