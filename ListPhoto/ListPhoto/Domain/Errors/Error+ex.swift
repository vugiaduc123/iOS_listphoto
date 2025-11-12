//
//  Error+ex.swift
//  ListPhoto
//
//  Created by Đức Vũ on 1/11/25.
//

import Foundation

extension Error {
    func asDomainAPIError() -> DomainAPIsError {
        if let domainError = self as? DomainAPIsError {
            return domainError
        } else if let decodingError = self as? DecodingError {
            return .decodingFailed
        } else if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return .noInternet
            case .timedOut: return .timeout
            case .cancelled: return .cancelled
            case .cannotDecodeContentData: return .decodingFailed
            case .badServerResponse: return .serverError(500)
            default: return .requestFailed(urlError)
            }
        } else {
            return .unknown
        }
    }
}
