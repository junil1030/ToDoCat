//
//  UIImage++.swift
//  ToDoCat
//
//  Created by 서준일 on 3/17/25.
//
import UIKit

//MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizedToMaxSize(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        if self.size.width <= maxWidth && self.size.height <= maxHeight {
            return self
        }
        
        let aspectWidth = maxWidth / self.size.width
        let aspectHeight = maxHeight / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        
        return resized(to: newSize)
    }
    
    func compressed(quality: CGFloat = 0.7) -> UIImage? {
        guard let data = jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }
}
