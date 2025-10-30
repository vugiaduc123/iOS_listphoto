//
//  CustomIndicator.swift
//  ListPhoto
//
//  Created by Vũ Đức on 17/12/24.
//

import Foundation
import UIKit

class PresentViewQR: NSObject {
    static let shared = PresentViewQR()
    private var window = UIWindow()
    private var overlayView = UIView()
    private let qrImageView = UIImageView()
    
    private override init() {
        super.init()
        configureFrameWindow()
        
        if overlayView.superview == nil {
            configrueOverlayView()
            
            setUpStyleView()
            addSubviewsToOverlay()
            setUpConstraint()
        }
        
        overlayView.isHidden = false
        overlayView.alpha = 0
    }
}
// MARK: Set Up and Constraint
extension PresentViewQR {
    private func configureFrameWindow() {
        if #available(iOS 15, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                
                if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    window = keyWindow
                } else {
                    window = UIWindow(windowScene: windowScene)
                }
            }
        } else {
            if let windowView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window = windowView
            } else {
                window = UIWindow(frame: UIScreen.main.bounds)
            }
        }
    }
    
    private func configrueOverlayView() {
        // style
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.tag = 333
        overlayView.isHidden = true
        
        // adTarget
        overlayView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(remove(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        if overlayView.superview == nil {
            // add View
            window.addSubview(overlayView)
        }
        
        constraintOverlayView()
    }
    
    private func addSubviewsToOverlay() {
        overlayView.addSubview(qrImageView)
    }
    
    private func setUpStyleView() {
        setupImageView()
        startRotatingImage()
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupImageView() {
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.image = UIImage(named: "indicator")
    }
    
    private func startRotatingImage() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 3
        rotation.repeatCount = .infinity
        qrImageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func setUpConstraint() {
        constraintViewContainer()
    }
    
    private func constraintOverlayView() {
        NSLayoutConstraint.activate([
            self.overlayView.topAnchor.constraint(equalTo: self.window.topAnchor),
            self.overlayView.bottomAnchor.constraint(equalTo: self.window.bottomAnchor),
            self.overlayView.leadingAnchor.constraint(equalTo: self.window.leadingAnchor),
            self.overlayView.trailingAnchor.constraint(equalTo: self.window.trailingAnchor)
        ])
    }
    
    private func constraintViewContainer() {
        NSLayoutConstraint.activate([
            self.qrImageView.centerXAnchor.constraint(equalTo: self.overlayView.centerXAnchor),
            self.qrImageView.centerYAnchor.constraint(equalTo: self.overlayView.centerYAnchor, constant: -25),
            self.qrImageView.heightAnchor.constraint(equalToConstant: 50),
            self.qrImageView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
}

// MARK: Handler
extension PresentViewQR {
    func showView(show: Bool) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
            if show {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    guard let self = self else { return }
                    overlayView.alpha = 1
                    overlayView.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.overlayView.alpha = 0
                }) { _ in
                    self.overlayView.isHidden = true
                }
            }
//        }
    }
    
    @objc func remove(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5, animations: {
                self.overlayView.alpha = 0
            }) { _ in
                self.overlayView.isHidden = true
            }
        }
    }
}
