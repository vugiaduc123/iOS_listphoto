//
//  PhotoUseCase.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

import Foundation
import Combine

public protocol PhotoUseCase {
    func fetchPhotos(page: Int, limit: Int) -> AnyPublisher<[PhotoEntity], DomainAPIsError>
}
