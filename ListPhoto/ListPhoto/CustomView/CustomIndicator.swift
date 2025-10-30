//
//  CustomIndicator.swift
//  ListPhoto
//
//  Created by Vũ Đức on 17/12/24.
//

import Foundation
import UIKit

class CustomLoadingIndicator: UIView {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        startRotatingImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
        startRotatingImage()
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "indicator")
    }

    private func startRotatingImage() {
         let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
         rotation.toValue = CGFloat.pi * 2
         rotation.duration = 3
         rotation.repeatCount = .infinity
         imageView.layer.add(rotation, forKey: "rotationAnimation")
     }
}
