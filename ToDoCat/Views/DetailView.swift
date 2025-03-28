//
//  DetailView.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//

import UIKit
import SnapKit

class DetailView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 16)
        label.textAlignment = .center
        label.text = "To Do"
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    lazy var createdTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.textAlignment = .right
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    lazy var updatedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.textAlignment = .right
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    let maxWidth: CGFloat = 400
    let maxHeight: CGFloat = 600
    lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        return image
    }()
    
    lazy var getCatButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("고양이 만나기", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var getDefaultImageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("기본 이미지 불러오기", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var getCustomImageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("내 사진 추가", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [getCatButton, getCustomImageButton, getDefaultImageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        //        stackView.isLayoutMarginsRelativeArrangement = true
        //        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return stackView
    }()
    
    lazy var contentText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.dohyeon(size: 12)
        textView.backgroundColor = UIColor(named: "BackgroundColor")
        textView.text = "할 일을 입력해보세요 !!"
        textView.textColor = .lightGray
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.isEditable = true
        textView.isScrollEnabled = true
        return textView
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 14)
        button.setTitle("할 일 추가", for: .normal)
        button.setTitleColor(UIColor(named: "CalendarSelectColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CalendarColor")
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var totalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, createdTimeLabel, updatedTimeLabel, titleImage, buttonStackView, contentText, addButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage?) {
        guard let image = image else { return }
        let resizedImage = image.resizedToMaxSize(maxWidth: maxWidth, maxHeight: maxHeight)
        titleImage.image = resizedImage
        
        let imageSize = resizedImage.size
        titleImage.snp.remakeConstraints { make in
            make.top.equalTo(updatedTimeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(imageSize.width)
            make.height.equalTo(imageSize.height)
        }
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "BackgroundColor")
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
//            make.top.equalTo(safeAreaLayoutGuide.snp.top)
//            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
//            make.leading.trailing.equalToSuperview()
            
            make.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        contentView.addSubview(totalStackView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            //make.width.equalTo(scrollView.snp.width)
            make.width.equalTo(self)
        }
        
        totalStackView.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview().inset(5) // 스크롤 가능하도록 설정
//            make.leading.equalToSuperview().inset(20) // 왼쪽 여백 20
//            make.trailing.equalToSuperview().inset(20) // 오른쪽 여백 20
//            make.width.equalTo(scrollView.snp.width).offset(-40) // 20 + 20만큼 줄이기
//            make.height.greaterThanOrEqualTo(scrollView.snp.height).priority(.low)
            
//            make.top.equalTo(scrollView.snp.top)
//            make.leading.equalTo(scrollView.snp.leading).offset(20)
//            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
//            make.width.equalTo(scrollView.snp.width).offset(-40)
            
//            make.top.bottom.equalToSuperview().inset(20)
//            make.leading.trailing.equalToSuperview().inset(20)
//            make.width.equalTo(scrollView.snp.width).offset(-40)
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
        }
        
        createdTimeLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        updatedTimeLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        
//        if let image = titleImage.image {
//            let resizedImage = image.resizedToMaxSize(maxWidth: maxWidth, maxHeight: maxHeight)
//            titleImage.image = resizedImage
//            
//            let imageSize = resizedImage.size
//            titleImage.snp.remakeConstraints { make in
//                make.top.equalTo(updatedTimeLabel.snp.bottom).offset(20)
//                make.centerX.equalToSuperview()
//                make.width.equalTo(imageSize.width)
//                make.height.equalTo(imageSize.height)
//            }
//        } else {
//            titleImage.snp.remakeConstraints { make in
//                make.top.equalTo(updatedTimeLabel.snp.bottom).offset(20)
//                make.centerX.equalToSuperview()
//                make.width.equalTo(400)
//                make.height.equalTo(400)
//            }
//        }
        
        titleImage.snp.makeConstraints { make in
            //            make.centerX.equalToSuperview()
            //            make.width.lessThanOrEqualTo(scrollView.snp.width).multipliedBy(0.4)
            //
            //            if let image = titleImage.image {
            //                let aspectRatio = image.size.height / image.size.width
            //                make.height.equalTo(titleImage.snp.width).multipliedBy(aspectRatio)
            //            } else {
            //                make.height.equalTo(titleImage.snp.width)
            //            }
            make.top.equalTo(updatedTimeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.9)
            
            // 이미지 비율 유지
            if let image = titleImage.image {
                let aspectRatio = image.size.height / image.size.width
                make.height.equalTo(titleImage.snp.width).multipliedBy(aspectRatio)
            } else {
                // 기본 이미지 크기 설정
                make.width.equalTo(300)
                make.height.equalTo(300)
            }
        }

        buttonStackView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(40)
        }
        
        contentText.snp.makeConstraints { make in
            make.height.equalTo(200).priority(.high)
        }
        
        addButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(50)
        }
    }
}
