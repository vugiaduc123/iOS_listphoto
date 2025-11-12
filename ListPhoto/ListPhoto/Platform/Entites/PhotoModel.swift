//
//  PhotoModel.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation

struct PhotoModel: Codable {
    var id: String
    var author: String
    var width: Int
    var height: Int
    var url: String
    var download_url: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.author = try container.decode(String.self, forKey: .author)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.url = try container.decode(String.self, forKey: .url)
        self.download_url = try container.decode(String.self, forKey: .download_url)
    }
}

