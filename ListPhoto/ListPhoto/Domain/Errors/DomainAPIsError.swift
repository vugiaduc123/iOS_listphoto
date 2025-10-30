//
//  DomainAPIsError.swift
//  ListPhoto
//
//  Created by Đức Vũ on 7/5/25.
//

import Foundation

public enum DomainAPIsError: Error, LocalizedError {
    // MARK: - Request formation
    case invalidURL
    case invalidRequest          // thêm — lỗi khi tạo URLRequest
    
    // MARK: - Transport (network layer)
    case noInternet
    case timeout
    case requestFailed(Error)
    case cancelled               // thêm — người dùng hủy request
    
    // MARK: - Response handling
//    case invalidResponse
    case invalidStatusCode(Int)  // thêm — để biết cụ thể code
    case clientError(Int)        // 400...499
    case serverError(Int)        // 500...599
    case invalidMinType         // mime type sai
//    case invalidData             // data rỗng hoặc không đúng format
    
    // MARK: - Decoding & Parsing
    case decodingFailed
    case deCodingError
    case endCodingError
    
    // MARK: - Retry & unknown
    case maxRetriesReached
    case unknown
}

extension DomainAPIsError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidRequest:
            return "Invalid request formation."
        case .noInternet:
            return "No internet connection."
        case .timeout:
            return "The request timed out."
        case .requestFailed(let error):
            return "Request failed with error: \(error.localizedDescription)"
        case .cancelled:
            return "The request was cancelled."
//        case .invalidResponse:
//            return "Invalid response from server."
        case .invalidStatusCode(let code):
            return "Unexpected status code: \(code)."
        case .clientError(let code):
            return "Client error (\(code))."
        case .serverError(let code):
            return "Server error (\(code))."
        case .invalidMinType:
            return "Unexpected content type."
//        case .invalidData:
//            return "Invalid or missing data."
        case .decodingFailed, .deCodingError:
            return "Failed to decode response."
        case .endCodingError:
            return "Failed to endCode response."
        case .maxRetriesReached:
            return "Maximum retries reached."
        case .unknown:
            return "An unknown error occurred."
        }
    }

}
