//
//  HomeView.swift
//  ToDoCat
//
//  Created by 서준일 on 3/12/25.
//

import UIKit

class HomeView: UIView {

    let hellolabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .black
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .white
        
        addSubview(hellolabel)
        
        hellolabel.translatesAutoresizingMaskIntoConstraints = false
        hellolabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        hellolabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
