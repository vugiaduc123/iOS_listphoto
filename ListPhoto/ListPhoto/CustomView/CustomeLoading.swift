//
//  CustomeLoading.swift
//  ListPhoto
//
//  Created by Đức Vũ on 7/5/25.
//

import Foundation
import UIKit

class CustomLoading: UIImageView {
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
        self.contentMode = .scaleAspectFit
        self.image = UIImage(named: "loading")
    }

    private func startRotatingImage() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 3
        rotation.repeatCount = .infinity
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
