//
//  SingleViewDoubleSpreadConfiguration.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/11/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

open class SingleViewDoubleSpreadConfiguration: DoubleSpreadConfiguration {
    override open var hasDifferentContentsForOrientation: Bool {
        true
    }

    override open func filter(_ originalContents: [PageViewContent], isLandscape: Bool) -> [PageViewContent] {
        if isLandscape == false {
            return originalContents
        }

        var newContents = [PageViewContent]()
        let chunkedContents = originalContents.rd_chunked(into: 2)
        for contents in chunkedContents {
            if contents.count == 2,
                let right = contents.first as? ImageContent,
                let left = contents.last as? ImageContent {
                newContents.append(DoubleImageContent(right: right, left: left))
            }
            else {
                for content in contents {
                    newContents.append(content)
                }
            }
        }
        return newContents
    }

    override open func interfaceBehavior(isDoubleSpread: Bool) -> InterfaceBehavior {
        if isDoubleSpread {
            return DoubleImagePagingBehavior()
        }
        return SinglePagingBehavior()
    }
}
