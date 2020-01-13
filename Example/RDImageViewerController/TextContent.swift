//
//  TextLabelViewContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class TextContent: PageContent {
    let text: String
    var forceFullscreenSize: Bool = false
    
    init(text: String) {
        self.text = text
        super.init(type: .nib(UINib(nibName: "TextLabelView", bundle: nil), TextLabelView.self))
    }
    
    open override func preload() {

    }
    
    open override func preload(completion: ((PageContent) -> Void)?) {

    }
    
    open override func stopPreload() {

    }
    
    open override func reload() {

    }
    
    open override func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, doubleSided: Bool) -> CGSize {
        if traitCollection.isLandscape(), doubleSided, forceFullscreenSize == false {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }
        
        return rect.size
    }
}
