//
//  APIPhotoUsecase.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

public final class APIPhotoUsecaseProvider: PhotoUseCaseProvider {
    public func makePhotoUseCase() -> any PhotoUseCase {
        return APIPhotoUsecase()
    }
}
