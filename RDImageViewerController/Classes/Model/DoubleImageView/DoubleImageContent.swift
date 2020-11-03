//
//  DoubleImageContent.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/11/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

open class DoubleImageContent: PageViewContent {
    var right: ImageContent?
    var left: ImageContent?

    private static let defaultMaximumZoomScale: CGFloat = 2.5
    var maximumZoomScale: CGFloat = defaultMaximumZoomScale

    init(right: ImageContent?, left: ImageContent?) {
        self.right = right
        self.left = left
        super.init(representation: .class(DoubleImageView.self))
    }

    override open func preload(completion: ((PagingViewLoadable) -> Void)?) {
        var callHandler: Bool {
            var result = false
            if let right = right {
                result = result || right.isPreloadable()
            }
            if let left = left {
                result = result || left.isPreloadable()
            }
            return result
        }
        defer {
            if callHandler {
                if let handler = completion {
                    handler(self)
                }
            }
        }
        if let right = right, right.isPreloadable() {
            right.preload()
        }
        if let left = left, left.isPreloadable() {
            left.preload()
        }
    }

    override open func preload() {
        preload(completion: nil)
    }

    override open func isPreloadable() -> Bool {
        true
    }

    override open func reload(completion: ((PagingViewLoadable) -> Void)?) {
        if let right = right {
            right.reload()
        }
        if let left = left {
            left.reload()
        }
        preload(completion: completion)
    }

    override open func stopPreload() {
        if let right = right {
            right.stopPreload()
        }
        if let left = left {
            left.stopPreload()
        }
    }

    override open func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize {
        return rect.size
    }
}
