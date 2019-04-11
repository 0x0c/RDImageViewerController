//
//  ReloadImageViewerController.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class ReloadImageViewerController: RDImageViewerController {
    override init(contents: [RDPageContentData], direction: RDPagingView.ForwardDirection) {
        super.init(contents: contents, direction: direction)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func reload() {
        currentPageIndex = 0
        let contents = ContentsFactory.randomContents()
        print(contents)
        update(contents: contents)
    }
}
