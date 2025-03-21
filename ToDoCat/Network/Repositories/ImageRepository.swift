//
//  ImageRepository.swift
//  ToDoCat
//
//  Created by 서준일 on 3/21/25.
//
import Foundation
import Alamofire

protocol ImageRepositoryProtocol {
    func fetchImage(from url: URL, completion: @escaping (Result<ImageEntity, Error>) -> Void)
}

class ImageRepository: ImageRepositoryProtocol {
    func fetchImage(from url: URL, completion: @escaping (Result<ImageEntity, Error>) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                let entity = ImageEntity(imageData: data)
                completion(.success(entity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
