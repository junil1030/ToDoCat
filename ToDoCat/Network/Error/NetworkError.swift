//
//  NetworkError.swift
//  ToDoCat
//
//  Created by 서준일 on 4/15/25.
//
import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidData
    case networkError(Error)
    case decodingError(Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "유요하지 않은 URL입니다."
        case .invalidData:
            return "유효하지 않은 데이터입니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "디코딩 오류: \(error.localizedDescription)"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
