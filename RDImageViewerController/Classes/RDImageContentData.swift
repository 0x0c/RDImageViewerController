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
    
    public override init(type: PresentationType) {
        super.init(type: .class(RDImageScrollView.self))
    }
    
    public init(image: UIImage) {
        super.init(type: .class(RDImageScrollView.self))
        self.image = image
    }
    
    public init(imageName: String, lazyLoad: Bool = false) {
        super.init(type: .class(RDImageScrollView.self))
        self.imageName = imageName
        if lazyLoad == false {
            preload()
        }
    }
    
    override open func preload() {
        if image == nil, let imageName = imageName {
            image = UIImage(named: imageName)
        }
    }
    
    open override func isPreloadable() -> Bool {
        return true
    }
    
    override open func reload() {
        image = nil
        preload()
    }
    
    override open func stopPreload() {
        
    }

    open override func reuseIdentifier() -> String {
        return "\(RDImageContentData.self)"
    }
}
