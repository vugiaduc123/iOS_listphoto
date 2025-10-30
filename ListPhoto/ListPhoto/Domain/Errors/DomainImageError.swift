//
//  DomainImageError.swift
//  ListPhoto
//
//  Created by Đức Vũ on 24/10/25.
//

import Foundation

public enum DomainImageError: Error, LocalizedError {
    // Network-level errors
    case invalidURL
    case noInternet
    case timeout
    case clientError(Int)
    case serverError(Int)
    case invalidResponse
    case invalidContentType
    case requestFailed(Error)

    // Data / Decode errors
    case invalidData
    case invalidImageData
    case decodingFailed(DecodingError)
    case emptyResponse

    // Logic / Retry
    case maxRetriesReached
    case unknown

    // MARK: - LocalizedError
    public var errorDescription: String? {
        switch self {
        // Network
        case .invalidURL: return "Invalid URL"
        case .noInternet: return "No internet connection"
        case .timeout: return "Request timed out"
        case .clientError(let code): return "Client error (\(code))"
        case .serverError(let code): return "Server error (\(code))"
        case .invalidResponse: return "Invalid server response"
        case .invalidContentType: return "Invalid content type"
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"

        // Data / Decode
        case .invalidData: return "Invalid data format"
        case .invalidImageData: return "Invalid image data"
        case .decodingFailed(let err): return "Decoding failed: \(err.localizedDescription)"
        case .emptyResponse: return "Empty response from server"

        // Logic
        case .maxRetriesReached: return "Max retry attempts reached"
        case .unknown: return "Unknown error"
        }
    }
}
