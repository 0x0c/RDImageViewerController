//
//  ScrollContentData.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class ScrollableContent: PageContent {
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(type: .nib(UINib(nibName: "ScrollContentView", bundle: nil), ScrollableContentView.self))
    }
    
    open override func preload() {
        
    }
    
    open override func preload(completion: ((PageContent) -> Void)?) {
        
    }
    
    open override func stopPreload() {
        
    }
    
    open override func reload() {
        
    }
}
