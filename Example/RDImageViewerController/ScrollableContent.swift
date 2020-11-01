//
//  ScrollContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class ScrollableContent: PageViewContent {
    let color: UIColor

    init(color: UIColor) {
        self.color = color
        super.init(type: .nib(UINib(nibName: "ScrollContentView", bundle: nil), ScrollableContentView.self))
    }

    override open func preload() {}

    override open func preload(completion: ((PagingViewLoadable) -> Void)?) {}

    override open func stopPreload() {}

    override open func reload() {}
}
