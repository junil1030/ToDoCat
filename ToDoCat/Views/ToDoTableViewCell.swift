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
    
    private let toDoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        // 기본 이미지 설정 (옵션)
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    
    private let contentPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
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
        
        contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(toDoImageView)
        containerStackView.addArrangedSubview(contentStackView)
        
        contentStackView.addArrangedSubview(dateTimeLabel)
        contentStackView.addArrangedSubview(contentPreviewLabel)
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        toDoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }

    }
    
    // MARK: - Configuration
    func configure(with item: ToDoItem) {
        contentPreviewLabel.text = item.content
        
        // 이미지 설정
        if let image = item.image {
            toDoImageView.image = image
            toDoImageView.tintColor = nil
        } else {
            toDoImageView.image = UIImage(systemName: "photo")
            toDoImageView.tintColor = .systemGray3
        }
        
        // 날짜 및 시간 포맷팅
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateTimeLabel.text = formatter.string(from: item.date)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentPreviewLabel.text = nil
        dateTimeLabel.text = nil
        toDoImageView.image = UIImage(systemName: "photo")
        toDoImageView.tintColor = .systemGray3
    }
}
