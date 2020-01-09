//
//  RDRemoteImageScrollView.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

open class RDRemoteImageScrollView: RDImageScrollView {
    var contentData: RDRemoteImageContent?
    
    open override func configure(data: RDPageContentProtocol, pageIndex: Int, traitCollection: UITraitCollection, doubleSided: Bool) {
        guard let data = data as? RDRemoteImageContent else {
            return
        }
        super.configure(data: data, pageIndex: pageIndex, traitCollection: traitCollection, doubleSided: doubleSided)
        contentData = data
        if data.image == nil {
            data.stopPreload()
            data.preload { [weak self] (content) in
                if let weakSelf = self, let cnt = content as? RDRemoteImageContent {
                    DispatchQueue.main.async {
                        if weakSelf.contentData == cnt {
                            weakSelf.image = cnt.image
                        }
                    }
                }
            }
        }
    }
    
}
