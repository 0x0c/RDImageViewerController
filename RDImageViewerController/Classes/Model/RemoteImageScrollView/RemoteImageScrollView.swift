//
//  RDRemoteImageScrollView.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

open class RemoteImageScrollView: ImageScrollView {
    var content: RemoteImageContent?

    override open func configure(data: PageContent, pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {
        guard let data = data as? RemoteImageContent else {
            return
        }
        super.configure(data: data, pageIndex: pageIndex, scrollDirection: scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
        content = data
        if data.image == nil {
            data.stopPreload()
            data.preload { [weak self] content in
                if let weakSelf = self, let cnt = content as? RemoteImageContent {
                    DispatchQueue.main.async {
                        if weakSelf.content == cnt {
                            weakSelf.image = cnt.image
                        }
                    }
                }
            }
        }
    }
}
