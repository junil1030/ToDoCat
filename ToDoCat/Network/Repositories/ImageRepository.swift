//
//  ImageRepository.swift
//  ToDoCat
//
//  Created by 서준일 on 3/21/25.
//
import Foundation
import Alamofire
import RxSwift

protocol ImageRepositoryProtocol {
    func fetchImage(from url: String) -> Single<ImageEntity>
}

class ImageRepository: ImageRepositoryProtocol {
    
    func fetchImage(from url: String) -> Single<ImageEntity> {
        return Single<ImageEntity>.create { observer in
            // url 검증 단계
            guard let iamgeURL = URL(string: url) else {
                observer(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            // 요청
            let request = AF.request(iamgeURL)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let imageEntity = ImageEntity(imageData: data)
                        observer(.success(imageEntity))
                    case .failure(let error):
                        observer(.failure(NetworkError.networkError(error)))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
