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
    public var landscapeMode: RDImageScrollView.LandscapeMode = .aspectFit
    public var image: UIImage?
    public var imageName: String?
    
    public override init(type: PresentationType) {
        super.init(type: type)
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
    
    open override func preload(completion: ((RDPageContentData) -> Void)?) {
        if image == nil, let imageName = imageName {
            image = UIImage(named: imageName)
            if let handler = completion {
                handler(self)
            }
        }
    }
    
    override open func preload() {
        preload(completion: nil)
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
    
    open override func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize {
        if direction.isHorizontal() == false, let image = image {
            let scale = rect.size.width / image.size.width
            let width = image.size.width * scale
            let height = image.size.height * scale
            return CGSize(width: width, height: height)
        }
        
        return UIScreen.main.bounds.size
    }
}
