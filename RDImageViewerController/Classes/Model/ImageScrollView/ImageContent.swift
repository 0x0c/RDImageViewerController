//
//  RDImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class ImageContent: PageViewContent, Equatable {
    public enum ContentType: Equatable {
        case name(_ string: String)
        case url(_ url: URL, imageDecodeHandler: ((Data) -> UIImage?)? = nil)
        
        public static func ==(lhs: ContentType, rhs: ContentType) -> Bool {
            switch (lhs, rhs) {
            case let (.name(left), .name(right)):
                return left == right
            case let (.url(left, _), .url(right, _)):
                return left == right
            default:
                return false
            }
        }
    }

    public enum LandscapeMode {
        case aspectFit
        case displayFit
    }

    public static func == (lhs: ImageContent, rhs: ImageContent) -> Bool {
        lhs.contentType == rhs.contentType
    }

    private static let defaultMaximumZoomScale: CGFloat = 2.5

    open var maximumZoomScale: CGFloat = defaultMaximumZoomScale
    open var landscapeMode: ImageContent.LandscapeMode = .aspectFit
    open var image: UIImage?
    open var contentType: ContentType

    public init(representation: PageViewRepresentation, type: ContentType = .name("")) {
        self.contentType = type
        super.init(representation: representation)
    }

    public convenience init(image: UIImage) {
        self.init(representation: .class(ImageScrollView.self))
        self.image = image
    }

    public convenience init(imageName: String, lazyLoad: Bool = false) {
        self.init(representation: .class(ImageScrollView.self), type: .name(imageName))
        if lazyLoad == false {
            preload()
        }
    }

    override open func preload(completion: ((PagingViewLoadable) -> Void)?) {
        switch contentType {
        case let .name(imageName):
            image = UIImage(named: imageName)
            if let handler = completion {
                handler(self)
            }
        case let .url(url, decodeHandler):
            URLSession(configuration: .default).dataTask(with: url) { [weak self] data, response, error in
                guard let weakSelf = self, let data = data else {
                    return
                }
                if let decodeHandler = decodeHandler {
                    weakSelf.image = decodeHandler(data)
                }
                else {
                    weakSelf.image = UIImage(data: data)
                }
                if let handler = completion {
                    handler(weakSelf)
                }
            }
        }
    }

    override open func preload() {
        preload(completion: nil)
    }

    override open func isPreloadable() -> Bool {
        true
    }

    override open func reload(completion: ((PagingViewLoadable) -> Void)?) {
        image = nil
        preload(completion: completion)
    }

    override open func stopPreload() {}

    override open func size(
        inRect rect: CGRect,
        direction: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) -> CGSize {
        if direction.isVertical, let image = image {
            var scale: CGFloat {
                if isDoubleSpread {
                    return (rect.size.width / 2.0) / image.size.width
                }
                return rect.size.width / image.size.width
            }

            let width = image.size.width * scale
            let height = image.size.height * scale
            return CGSize(width: width, height: height)
        }

        return super.size(
            inRect: rect,
            direction: direction,
            traitCollection: traitCollection,
            isDoubleSpread: isDoubleSpread
        )
    }
}
