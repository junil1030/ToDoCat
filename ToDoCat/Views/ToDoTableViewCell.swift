//
//  ToDoTableViewCell.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//

import UIKit
import SnapKit

class ToDoTableViewCell: UITableViewCell {
    
    private let toDoimageView: UIImageView = {
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
        label.textAlignment = .right
        return label
    }()
    
    private let contentPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2  // 최대 2줄로 제한
        return label
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
        contentView.addSubview(toDoimageView)
        contentView.addSubview(dateTimeLabel)
        contentView.addSubview(contentPreviewLabel)
        
        toDoimageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        dateTimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.greaterThanOrEqualTo(contentPreviewLabel.snp.trailing).offset(8)
        }
        
        contentPreviewLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTimeLabel).offset(4)
            make.leading.equalTo(toDoimageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
