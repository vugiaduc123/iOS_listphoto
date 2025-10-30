//
//  BaseViewController.swift
//  ListPhoto
//
//  Created by Đức Vũ on 10/5/25.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    var disposeBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = NetworkMonitor.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { current in
                switch current {
                case .strongConnection:
                    print("✅ Mạng mạnh, có thể tải hình lớn.")
                    self.showToast(message: "✅ Connect internet", duration: 4)
                case .weakConnection:
                    print("⚠️ Mạng yếu, cân nhắc giảm tải hoặc retry.")
                    self.showToast(message: "⚠️ Mạng yếu, cân nhắc giảm tải hoặc retry.", duration: 3)
                case .disconnected:
                    print("❌ Không có mạng.")
                    self.showToast(message: "❌ Disconnect Wifi.", duration: 3)
                case .normal: break
                }
            }.store(in: &disposeBag)
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        // Label hiển thị nội dung
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.textColor = .white
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.layer.cornerRadius = 12
        toastLabel.layer.masksToBounds = true
        
        // Kích thước giới hạn
        let maxWidthPercentage: CGFloat = 0.8
        let maxMessageSize = CGSize(width: view.frame.size.width * maxWidthPercentage, height: .greatestFiniteMagnitude)
        var expectedSize = toastLabel.sizeThatFits(maxMessageSize)
        expectedSize.width += 24
        expectedSize.height += 16
        
        // Vị trí: dưới cùng, giữa ngang
        toastLabel.frame = CGRect(
            x: (view.frame.size.width - expectedSize.width) / 2,
            y: view.frame.size.height - expectedSize.height - 100,
            width: expectedSize.width,
            height: expectedSize.height
        )
        
        view.addSubview(toastLabel)
        
        // Animation: fade in → giữ → fade out
        // ⚡ Animation xuất hiện (fade-in + trượt lên)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 1.0
            toastLabel.transform = .identity
        }) { _ in
            // ⏳ Giữ trong 2s (mặc định) rồi ẩn đi
            UIView.animate(withDuration: 0.4, delay: duration, options: .curveEaseIn, animations: {
                toastLabel.alpha = 0.0
                toastLabel.transform = CGAffineTransform(translationX: 0, y: 30)
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
