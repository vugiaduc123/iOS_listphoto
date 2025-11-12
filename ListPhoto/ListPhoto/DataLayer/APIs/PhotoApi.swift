//
//  PhotoApi.swift
//  ListPhoto
//
//  Created by Đức Vũ on 20/10/25.
//

import Foundation
import Combine

struct PhotoListRequest: APIClient {
    typealias Model = [PhotoDTOs]

    var environment: APIEnvironment {
        DefaultEnviroment()
    }

    var path: String {
        return "/v2/list"
    }

    var headers: [String: String]? {
        return nil
    }
    var loadingSubject: CurrentValueSubject<Bool, Never>

    var errorSubject: PassthroughSubject<any Error, Never>

    init(loadingSubject: CurrentValueSubject<Bool, Never> = .init(false),
         errorSubject:   PassthroughSubject<any Error, Never> = .init()) {
      self.loadingSubject = loadingSubject
      self.errorSubject   = errorSubject
    }
}


