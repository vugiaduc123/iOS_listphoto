//
//  UIImageView.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    func resizedWithAspectFit(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        let aspectWidth = maxWidth / size.width
        let aspectHeight = maxHeight / size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let newSize = CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)
        return resized(to: newSize)
    }
}
