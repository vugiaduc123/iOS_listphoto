//
//  PhotoDTOs.swift
//  ListPhoto
//
//  Created by Đức Vũ on 20/10/25.
//

import Foundation

public struct PhotoDTOs: Codable {
    let id: String
    var author: String
    var width: Int
    var height: Int
    var url: String
    var downloadURL: String

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}
