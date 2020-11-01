//
//  TextLabelViewContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class TextContent: Content {
    let text: String
    var forceFullscreenSize: Bool = false

    init(text: String) {
        self.text = text
        super.init(type: .nib(UINib(nibName: "TextLabelView", bundle: nil), TextLabelView.self))
    }

    override open func preload() {}

    override open func preload(completion: ((PageContent) -> Void)?) {}

    override open func stopPreload() {}

    override open func reload() {}

    override open func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize {
        if RDImageViewerController.rd_isLandscape(), isDoubleSpread, forceFullscreenSize == false {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }

        return rect.size
    }
}
