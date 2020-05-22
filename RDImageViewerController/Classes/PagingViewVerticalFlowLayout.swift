//
//  RDPagingViewVerticalFlowLayout.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

class PagingViewVerticalFlowLayout: PagingViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .vertical
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
