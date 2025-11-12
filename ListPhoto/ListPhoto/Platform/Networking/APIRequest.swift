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
    func fullURL(with parameters: [String: Any]?) -> URL
}

extension APIRequest {
    func fullURL(with parameters: [String: Any]?) -> URL {
        var components = URLComponents(string: environment.baseURL + path)
        if let params = parameters {
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        guard let url = components?.url else {
            fatalError("Invalid URL")
        }
        return url
    }

    func displayInformation() {
        print("Path URL: \(path)")
        print("Full URL: \(String(describing: fullURL))")
    }

}
