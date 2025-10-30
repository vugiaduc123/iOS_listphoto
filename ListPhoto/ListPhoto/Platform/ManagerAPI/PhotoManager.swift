//
//  PhotoManager.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit
import Network

class PhotoManager {
    static var shared = PhotoManager()
    let result = PhotoListRequest()
    
    func getApiPhoto(completion: @escaping ([PhotoModel]) -> Void) {
        result.execute(method: .get, parameters: ["page": 0, "limit": 100]) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let err):
                print("API Called failed with error \(err.localizedDescription)")
            }
        }
    }
    
    func getLoadMore(page: Int, limit: Int, completion: @escaping ([PhotoModel]) -> Void) {
        result.execute(method: .get, parameters: ["page": page, "limit": limit]) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let err):
                print("API Called failed with error \(err.localizedDescription)")
            }
        }
    }
}


