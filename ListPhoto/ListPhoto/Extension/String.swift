//
//  String.swift
//  ListPhoto
//
//  Created by Vũ Đức on 17/12/24.
//

import Foundation
import UIKit

extension String {
    func htmlEncoded() -> String {
        var result = self
        let htmlEntities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;" : "\"",
            "&#39;": "'"
        ]
        for (character, encoded) in htmlEntities {
            result = result.replacingOccurrences(of: character, with: encoded)
        }
        return result
    }
}
