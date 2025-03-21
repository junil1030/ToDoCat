//
//  ImageService.swift
//  ToDoCat
//
//  Created by 서준일 on 3/21/25.
//
import UIKit

enum ImageServiceError: Error {
    case invalidData
    case networkError(Error)
}

protocol ImageServiceProtocol {
    func getImage(from urlString: String, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void)
}

class ImageService: ImageServiceProtocol {
    private let repository: ImageRepositoryProtocol
    
    init(repository: ImageRepositoryProtocol) {
        self.repository = repository
    }
    
    func getImage(from urlString: String, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) {
        guard let urlString = URL(string: urlString) else {
            completion(.failure(.invalidData))
            return
        }
        
        repository.fetchImage(from: urlString) { result in
            switch result {
            case .success(let entity):
                guard let image = UIImage(data: entity.imageData) else {
                    completion(.failure(.invalidData))
                    return
                }
                completion(.success(image))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
