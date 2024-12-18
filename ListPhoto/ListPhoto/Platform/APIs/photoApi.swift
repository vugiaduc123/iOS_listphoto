//
//  photoApi.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

struct PhotoAPI: APIClient {
    
    typealias Model = [PhotoModel]

    var enviroment: APIEnvironment {
        return DefaultEnviroment()
    }
    var page: Int

    var limit: Int

    var path: String {
        return "/v2/list?page=\(page)&amp;limit=\(limit)"
    }
}


