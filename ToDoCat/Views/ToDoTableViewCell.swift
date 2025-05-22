//
//  ToDoTableViewCell.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//

import UIKit
import SnapKit

class ToDoTableViewCell: UITableViewCell {
    
    static let identifier = "ToDoTableViewCell"
    
    let checkBoxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        button.tintColor = UIColor(named: "CalendarColor")
        return button
    }()
    
    private let toDoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 12)
        label.textColor = UIColor(named: "TextColor")
        label.textAlignment = .left
        return label
    }()
    
    private let contentPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.dohyeon(size: 14)
        label.textColor = UIColor(named: "TextColor")
        label.numberOfLines = 2  // 최대 2줄로 제한
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.alignment = .leading
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    var onCheckBoxToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupCell()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupCell()
     }

    private func setupCell() {
        self.selectionStyle = .none
        backgroundColor = UIColor(named: "CellBackgroundColor")
        
        contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(checkBoxButton)
        containerStackView.addArrangedSubview(toDoImageView)
        containerStackView.addArrangedSubview(contentStackView)
        
        contentStackView.addArrangedSubview(dateTimeLabel)
        contentStackView.addArrangedSubview(contentPreviewLabel)
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        checkBoxButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        toDoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        checkBoxButton.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
    }
    
    @objc private func checkBoxTapped() {
        onCheckBoxToggle?()
    }
    
    // MARK: - Configuration
    func configure(with item: ToDoItem) {
        contentPreviewLabel.text = item.content
        
        checkBoxButton.isSelected = item.isCompleted
        
        if let image = item.image {
            toDoImageView.image = image
            toDoImageView.tintColor = nil
        } else {
            toDoImageView.image = UIImage(systemName: "photo")
            toDoImageView.tintColor = .systemGray3
        }
        
        dateTimeLabel.text = item.date.toString()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentPreviewLabel.text = nil
        dateTimeLabel.text = nil
        toDoImageView.image = UIImage(systemName: "photo")
        toDoImageView.tintColor = .systemGray3
    }
}
