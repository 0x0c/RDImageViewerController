//
//  RDRemoteImageScrollView.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

class RDRemoteImageScrollView: RDImageScrollView {

    func configure(data: RDRemoteImageContentData) {
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
