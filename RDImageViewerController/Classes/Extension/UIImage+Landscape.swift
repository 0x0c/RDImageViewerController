//
//  UIImage+Landscape.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/11/02.
//

import UIKit

extension UIImage {
    func rd_isLandspace() -> Bool {
        size.width > size.height
    }
}
