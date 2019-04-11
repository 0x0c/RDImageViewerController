//
//  RDRemoteImageScrollView.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

open class RDRemoteImageScrollView: RDImageScrollView {

    open override func configure(data: RDPageContent) {
        guard let data = data as? RDRemoteImageContentData else {
            return
        }
        if data.image == nil {
            data.preload { [weak self] (downloadedImage) in
                if let weakSelf = self, let newImage = downloadedImage {
                    DispatchQueue.main.async {
                        weakSelf.image = newImage
                    }
                }
            }
        }
    }
    
}
