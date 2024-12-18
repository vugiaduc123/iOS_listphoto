//
//  APIEnviroments.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
protocol APIEnvironment {
    var baseURL: String { get }
}
struct DefaultEnviroment: APIEnvironment {
    var baseURL: String {
        return "https://picsum.photos"
    }
}
