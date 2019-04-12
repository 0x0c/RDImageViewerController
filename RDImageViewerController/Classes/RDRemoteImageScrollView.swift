//
//  RDRemoteImageScrollView.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

open class RDRemoteImageScrollView: RDImageScrollView {

    open override func configure(data: RDPageContentProtocol) {
        guard let data = data as? RDRemoteImageContentData else {
            return
        }
        super.configure(data: data)
        data.stopPreload()
        data.preload { [weak self] (content) in
            if let weakSelf = self, let cnt = content as? RDRemoteImageContentData {
                DispatchQueue.main.async {
                    weakSelf.image = cnt.image
                }
            }
        }
    }
    
}
