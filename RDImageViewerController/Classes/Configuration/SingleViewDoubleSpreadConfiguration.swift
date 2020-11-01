//
//  SingleViewDoubleSpreadConfiguration.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/11/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

open class SingleViewDoubleSpreadConfiguration: DoubleSpreadConfiguration {
    open override var hasDifferentContentsForOrientation: Bool {
        true
    }

    open override func filter(_ originalContents: [Content], isLandscape: Bool) -> [Content] {
        if isLandscape == false {
            return originalContents
        }

        var newContents = [Content]()
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
    
    open override func interfaceBehavior(isDoubleSpread: Bool) -> InterfaceBehavior {
        if isDoubleSpread {
            return DoubleImagePagingBehavior()
        }
        return SinglePagingBehavior()
    }
}
