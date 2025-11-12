//
//  GraphicRecommend.swift
//  ListPhoto
//
//  Created by Đức Vũ on 24/10/25.
//

import UIKit

public struct GraphicImage {
    private let screenSize: CGSize
    private let scaleFactor: CGFloat
    private let pixelSize: CGSize
    private let getPhysicalMemory: CGSize

    private init(screenSize: CGSize, scaleFactor: CGFloat, pixelSize: CGSize, getPhysicalMemory: CGSize) {
        self.screenSize = screenSize
        self.scaleFactor = scaleFactor
        self.pixelSize = pixelSize
        self.getPhysicalMemory = getPhysicalMemory
    }

    private static func current() -> GraphicImage {
        let screen = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let getPhysicalMemory = ProcessInfo.processInfo.physicalMemory >= (4 * 1024 * 1024 * 1024) ? CGSize(width: 4096, height: 4096) : CGSize(width: 2048, height: 2048) // > 4GB ram

        return GraphicImage(screenSize: screen,
                                scaleFactor: scale,
                                pixelSize: CGSize(width: (screen.width * scale),
                                                  height: (screen.height * scale)),
                                getPhysicalMemory: getPhysicalMemory)
    }

    static func getRecommendGraphic() -> CGSize {
        let getConfig = GraphicImage.current()

        let recommendWith:CGFloat = min(getConfig.pixelSize.width,
                                        getConfig.getPhysicalMemory.width)

        let recommendHeight:CGFloat = min(getConfig.pixelSize.height,
                                          getConfig.getPhysicalMemory.height)

        return CGSize(width: recommendWith, height: recommendHeight)
    }
}
