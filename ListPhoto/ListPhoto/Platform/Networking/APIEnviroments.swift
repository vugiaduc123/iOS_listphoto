//
//  APIEnviroments.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol APIEnvironment {
    var baseURL: String { get }
    var headers: [String: String]? { get }
}

struct DefaultEnviroment: APIEnvironment {
    var baseURL: String {
        return "https://picsum.photos"
    }
    
    var headers: [String : String]? {
        return nil
    }
}
