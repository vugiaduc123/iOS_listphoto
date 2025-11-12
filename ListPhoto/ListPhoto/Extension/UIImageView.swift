//
//  UIImageView.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

extension UIImage {
<<<<<<< HEAD
    func renderImage() -> UIImage {
        let maxDimensionDeviceCurrent = max(GraphicImage.getRecommendGraphic().width,
                               GraphicImage.getRecommendGraphic().height)
        let maxSide = max(size.width, size.height)

        if maxSide <= maxDimensionDeviceCurrent {
            return self
        }

        let ratio = maxDimensionDeviceCurrent / maxSide
        let newSize = CGSize(width: size.width * ratio,
                             height: size.height * ratio)

        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { ctx in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func decodedImage() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        if let newCG = context?.makeImage() {
            return UIImage(cgImage: newCG)
        }
        return self
    }

=======
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
>>>>>>> 3404a3230b2633a709d53b397211244b9c4e1f7e
}
