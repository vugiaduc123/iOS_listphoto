//
//  UIImageView.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit

extension UIImage {
    /// Resize nếu kích thước lớn hơn maxDimension
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

    /// Compress bằng binary search để <= maxFileSizeMB
    func prepareForUpload(maxFileSizeMB: Int) -> Data? {
        let maxBytes = maxFileSizeMB * 1024 * 1024
        var minQ: CGFloat = 0.0
        var maxQ: CGFloat = 1.0
        var bestData: Data? = nil
        
        // dùng sai số thay vì step fix 0.01
        while (maxQ - minQ) > 0.01 {
            let midQ = (minQ + maxQ) / 2
            guard let data = self.jpegData(compressionQuality: midQ) else {
                return bestData
            }
            
            if data.count > maxBytes {
                maxQ = midQ
            } else {
                bestData = data
                minQ = midQ
            }
        }
        return bestData
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
