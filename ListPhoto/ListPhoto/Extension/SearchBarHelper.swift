//
//  SearchBarHelper.swift
//  ListPhoto
//
//  Created by Vũ Đức on 19/12/24.
//

import Foundation
import UIKit
extension UISearchBar {
    func disableSwipeTyping() {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.autocorrectionType = .no    // Disable auto-correction
            textField.smartInsertDeleteType = .no // Disable smart insert/delete
            textField.autocapitalizationType = .none // Disable capitalization
            textField.spellCheckingType = .no     // Disable spell checking
        }
    }
}
