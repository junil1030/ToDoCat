//
//  ImageService+Rx.swift
//  ToDoCat
//
//  Created by 서준일 on 4/11/25.
//

import UIKit
import RxSwift

protocol RxImageServiceProtocol {
    
    func rx_getImage(from urlString: String) -> Single<UIImage>
}

extension ImageService: RxImageServiceProtocol {
    
    func rx_getImage(from urlString: String) -> Single<UIImage> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(ImageServiceError.invalidData))
                return Disposables.create()
            }
            
            self.getImage(from: urlString) { result in
                switch result {
                case .success(let image):
                    single(.success(image))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
