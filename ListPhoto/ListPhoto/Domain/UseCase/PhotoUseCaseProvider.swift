//
//  PhotoUseCaseProvider.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

import Foundation

public protocol PhotoUseCaseProvider {
    func makePhotoUseCase() -> PhotoUseCase
}
