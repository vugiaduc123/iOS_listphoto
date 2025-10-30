//
//  PhotoMapper.swift
//  ListPhoto
//
//  Created by Đức Vũ on 20/10/25.
//

import Foundation

extension PhotoDTOs {
    func toEntity() -> PhotoEntity {
        return PhotoEntity(id: id,
                           author: author,
                           width: width,
                           height: height,
                           url: url,
                           downloadURL: downloadURL)
    }
    
    static func fromEntity(_ entity: PhotoEntity) -> PhotoDTOs {
        return PhotoDTOs(id: entity.id,
                         author: entity.author,
                         width: entity.width,
                         height: entity.height,
                         url: entity.url,
                         downloadURL: entity.downloadURL)
    }
}
