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
        label.font = UIFont.dohyeon(size: 10)
        label.textAlignment = .right
        label.textColor = .gray
        return label
    }()
    
    lazy var titleImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var getCatButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("고양이 만나기", for: .normal)
        return button
    }()
    
    lazy var getDogButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.dohyeon(size: 10)
        button.setTitle("강아지 만나기", for: .normal)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [getCatButton, getDogButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
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
    
    lazy var totalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, timeLabel, titleImage, buttonStackView, contentText])
        stackView.spacing = 3
        stackView.alignment = .fill
        stackView.axis = .vertical
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
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
