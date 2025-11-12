//
//  UIImageView.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

extension UIImage {
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

}
