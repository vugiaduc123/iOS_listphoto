//
//  PhotoNavigator.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

class PhotoNavigator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func navigateToEventScreen() {
        let photoNavigator = PhotoNavigator(navigationController: self.navigationController)
        let photoViewModel = PhotoViewModel(navigator: photoNavigator)
        let photoVC = ListPhotoViewController(viewModel: photoViewModel)
        navigationController.pushViewController(photoVC, animated: true)
    }
}
