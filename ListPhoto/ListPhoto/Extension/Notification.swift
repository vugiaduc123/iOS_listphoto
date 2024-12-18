//
//  Notification.swift
//  ListPhoto
//
//  Created by Vũ Đức on 17/12/24.
//

import Foundation
import UIKit

extension Notification.Name {
    static let imageLoaded = Notification.Name("imageLoaded")
}

enum MonitorInternet: String {
    case satisfied = "Connected to the internet"
    case noInternet = "No internet connection"
}

extension UINavigationBar {
  func changeBackgroundColor(backroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
    if #available(iOS 15, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear // hide underline bar
        appearance.shadowImage = UIImage() //  hide underline bar
      if let backroundColor = backroundColor {
        appearance.backgroundColor = backroundColor
      }
      if let titleColor = titleColor {
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
      }
      standardAppearance = appearance
      scrollEdgeAppearance = appearance
    } else {
      barStyle = .blackTranslucent
      if let backroundColor = backroundColor {
        barTintColor = backroundColor
      }
      if let titleColor = titleColor {
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
      }
    }
  }
}
