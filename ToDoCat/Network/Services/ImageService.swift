//
//  ImageService.swift
//  ToDoCat
//
//  Created by 서준일 on 3/21/25.
//
import UIKit
import RxSwift

protocol ImageServiceProtocol {
    func getImage(from urlString: String) -> Single<UIImage>
}

class ImageService: ImageServiceProtocol {
    private let repository: ImageRepositoryProtocol
    
    init(repository: ImageRepositoryProtocol = ImageRepository()) {
        self.repository = repository
    }
    
    func getImage(from urlString: String) -> Single<UIImage> {
        return repository.fetchImage(from: urlString)
            .map { entity -> UIImage in
                guard let image = entity.toImage else {
                    throw NetworkError.invalidData
                }
                return image
            }
    }
}
