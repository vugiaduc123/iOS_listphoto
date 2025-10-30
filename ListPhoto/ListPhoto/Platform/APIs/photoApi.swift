//
//  photoApi.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

struct PhotoListRequest: APIClient {
    
    typealias Model = [PhotoModel]
    
    var environment: APIEnvironment {
        DefaultEnviroment()
    }
    
    var path: String {
        return "/v2/list"
    }
    
    var headers: [String: String]? {
        return nil
    }
}


