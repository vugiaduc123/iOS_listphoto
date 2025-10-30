//
//  APIRequest.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

protocol APIRequest {
    var environment: APIEnvironment { get }
    var path: String { get }
    var headers: [String: String]? { get }
    func fullURL() -> URL
}

extension APIRequest {
    func fullURL() -> URL {
        guard let url = URL(string: "\(environment.baseURL + path)") else {
            fatalError(DomainAPIsError.invalidURL.localizedDescription)
        }
        return url
    }
    
    func displayInformation() {
        print("Path URL: \(path)")
        print("Full URL: \(String(describing: fullURL))")
    }
    
}
