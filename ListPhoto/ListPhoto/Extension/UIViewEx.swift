//
//  UIViewEx.swift
//  ListPhoto
//
//  Created by Đức Vũ on 21/9/25.
//
import UIKit
// MARK: Skeleton Extension
extension UIView {
    private static let shimmerAnimationKey = "shimmer"
    
    func showSkeleton() {
        DispatchQueue.main.async {
            // Xóa skeleton cũ đồng bộ
            self.layer.sublayers?.removeAll(where: { $0.name == "skeletonGradient" })
            
            // Tạo gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.name = "skeletonGradient"
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = self.layer.cornerRadius
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.colors = [
                UIColor(white: 0.85, alpha: 1.0).cgColor,
                UIColor(white: 0.75, alpha: 1.0).cgColor,
                UIColor(white: 0.85, alpha: 1.0).cgColor
            ]
            gradientLayer.locations = [0, 0.5, 1]
            
            // Animation
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.duration = 1.2
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: UIView.shimmerAnimationKey)
            
            self.layer.addSublayer(gradientLayer)
        }
    }
    
    func hideSkeleton() {
        DispatchQueue.main.async {
            self.layer.sublayers?.removeAll(where: { $0.name == "skeletonGradient" })
        }
    }
}
