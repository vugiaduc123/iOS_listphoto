//
//  APIRequest.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

protocol APIRequest {
    var enviroment: APIEnvironment { get }
    
    var path: String { get }
}

extension APIRequest {
    
    var fullURL: URL {
        let encodeHTML = enviroment.baseURL.appending(path).htmlEncoded()
        guard let baseURL = URL(string: encodeHTML) else {
            fatalError("Base URL is invalid")
        }
        return baseURL
    }
    
    func displayInformation() {
        print("Path URL: \(path)")
        print("Full URL: \(fullURL)")
    }
    
}
