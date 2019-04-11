//
//  TextLabelViewContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class TextLabelViewContentData: RDPageContentData {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(type: .nib(UINib(nibName: "TextLabelView", bundle: nil), TextLabelView.self))
    }
    
    open override func preload() {

    }
    
    open override func preload(completion: ((RDPageContentData) -> Void)?) {

    }
    
    open override func stopPreload() {

    }
    
    open override func reload() {

    }
    
    override func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize {
        return rect.size
    }
}
