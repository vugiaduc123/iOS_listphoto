//
//  PhotoNavigator.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

protocol GenerateListNavigator {
    func openDetailListPhoto(_ navigationController: UINavigationController?)
}

class DefaultPhotoGenerateListNavigator: GenerateListNavigator {
    func openDetailListPhoto(_ navigationController: UINavigationController?) {
        let photoProvider = APIPhotoUsecaseProvider()
        let photoViewModel = PhotoViewModel(useCase: photoProvider.makePhotoUseCase())
        let photoViewController = ListPhotoViewController(viewModel: photoViewModel)
        
        navigationController?.pushViewController(photoViewController, animated: true)
    }
}

