//
//  PhotoManager.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit
import Network
import Combine

final class APIPhotoUsecase: PhotoUseCase {
    private let request = PhotoListRequest()
    
    func fetchPhotos(page: Int, limit: Int) -> AnyPublisher<[PhotoEntity], DomainAPIsError> {
        request.request(method: .get, parameters: ["page": page, "limit": limit])
            .map({ dtos in
                dtos.map { $0.toEntity() }
            })
            .mapError { error -> DomainAPIsError in
                return error
            }
            .eraseToAnyPublisher()
    }
}

