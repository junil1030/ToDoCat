//
//  ImageRepository+Rx.swift
//  ToDoCat
//
//  Created by 서준일 on 4/11/25.
//

import Foundation
import RxSwift
import Alamofire

protocol RxImageRepositoryProtocol {
    
    func rx_fetchImage(from url: URL) -> Single<ImageEntity>
}

extension ImageRepository: RxImageRepositoryProtocol {
    
    func rx_fetchImage(from url: URL) -> Single<ImageEntity> {
        return Single.create { single in
            let request = AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    let entity = ImageEntity(imageData: data)
                    single(.success(entity))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
