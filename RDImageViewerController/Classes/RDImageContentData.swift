//
//  RDImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class RDImageContentData: RDPageContentData {
    static let DefaultMaximumZoomScale: CGFloat = 2.5
    
    public var maximumZoomScale: CGFloat = DefaultMaximumZoomScale
    public var landscapeMode: RDImageScrollView.ResizeMode = .aspectFit
    public var image: UIImage?
    public var imageName: String?
    
    public init(image: UIImage) {
        super.init()
        self.image = image
    }
    
    public init(imageName: String) {
        super.init()
        self.imageName = imageName
    }
    
    override public func contentView(frame: CGRect) -> UIView {
        return RDImageScrollView(frame: frame)
    }
    
    override public func preload() {
        if image == nil, let imageName = imageName {
            image = UIImage(named: imageName)
        }
    }
    
    override public func reload() {
        image = nil
        preload()
    }
    
    override public func stopPreload() {
        
    }
    
    override public func configure(view: UIView) {
        let imageView = view as! RDImageScrollView
        imageView.maximumZoomScale = maximumZoomScale
        imageView.mode = landscapeMode
        imageView.setZoomScale(1.0, animated: false)
        imageView.image = image
    }

}
