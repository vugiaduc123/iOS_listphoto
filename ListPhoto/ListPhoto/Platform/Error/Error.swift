//
//  Errỏ.swift
//  ListPhoto
//
//  Created by Đức Vũ on 7/5/25.
//

import Foundation

enum ErrorAPI: Error {
    case invalidURL
    case noInternet
    case invalidImageData
    case timeout
    case maxRetriesReached
}
