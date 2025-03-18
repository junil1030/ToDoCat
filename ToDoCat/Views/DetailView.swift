//
//  DetailView.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//

import UIKit
import SnapKit

class DetailView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 16)
        label.textAlignment = .center
        label.text = "To Do"
        label.textColor = .black
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.text = Date().toString(format: "yyyy-MM-dd")
        label.textAlignment = .right
        label.textColor = .gray
        return label
    }()
    
    lazy var titleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "photo.badge.magnifyingglass")?.resized(to: CGSize(width: 40, height: 40))
        return image
    }()
    
    lazy var getCatButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("고양이 만나기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var getDogButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("강아지 만나기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [getCatButton, getDogButton, getCustomImageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
//        stackView.isLayoutMarginsRelativeArrangement = true
//        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return stackView
    }()
    
    lazy var contentText: UITextView = {
        let textView = UITextView()
        textView.text = "할 일을 입력해보세요"
        textView.font = UIFont.dohyeon(size: 12)
        textView.textColor = .black
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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var totalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, timeLabel, titleImage, buttonStackView, contentText, addButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(totalStackView)
        
        totalStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        let safeAreaHeight = UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 40
        
        // titleImage와 contentText에 각각 30%의 높이 할당
        titleImage.snp.makeConstraints { make in
            make.height.equalTo(safeAreaHeight * 0.3)
        }
        
        contentText.snp.makeConstraints { make in
            make.height.equalTo(safeAreaHeight * 0.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(10)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(10)
        }
        
        addButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(10)
        }
    }
}
