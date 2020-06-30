//
//  ReloadImageViewerController.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class ReloadImageViewerController: RDImageViewerController {
    override init(contents: [PageContent], direction: PagingView.ForwardDirection) {
        super.init(contents: contents, direction: direction)
        let items = [UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload)), UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(push))]
        navigationItem.setRightBarButtonItems(items, animated: true)
    }

    @objc func reload() {
        currentPageIndex = 0.convert(double: isDoubleSpread)
        let contents = ContentsFactory.randomContents()
        print(contents)
        update(contents: contents)
    }

    @objc func push() {
        let viewController = ReloadImageViewerController(contents: ContentsFactory.scrollContents(), direction: pagingView.scrollDirection)
        viewController.showSlider = showSlider
        viewController.showPageNumberHud = showPageNumberHud
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
}
