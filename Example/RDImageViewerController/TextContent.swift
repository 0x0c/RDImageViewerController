//
//  TextLabelViewContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class TextContent: RDPageContent {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(type: .nib(UINib(nibName: "TextLabelView", bundle: nil), TextLabelView.self))
    }
    
    open override func preload() {

    }
    
    open override func preload(completion: ((RDPageContent) -> Void)?) {

    }
    
    open override func stopPreload() {

    }
    
    open override func reload() {

    }
}
