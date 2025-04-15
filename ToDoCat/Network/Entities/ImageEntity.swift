//
//  ImageEntity.swift
//  ToDoCat
//
//  Created by 서준일 on 3/21/25.
//
import UIKit

struct ImageEntity {
    let imageData: Data
    
    var toImage: UIImage? {
        return UIImage(data: imageData)
    }
}
