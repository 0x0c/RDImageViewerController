//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public struct ImageAlignment {
    public enum HorizontalAlignment {
        case left
        case right
        case center
    }

    public enum VerticalAlignment {
        case top
        case bottom
        case center
    }

    public var horizontal: HorizontalAlignment = .center
    public var vertical: VerticalAlignment = .center
}

public protocol Content {
    func isPreloadable() -> Bool
    func isPreloading() -> Bool
    func preload()
    func preload(completion: ((_PageContent) -> Void)?)
    func stopPreload()
    func reload()
    func reload(completion: ((_PageContent) -> Void)?)
    func reuseIdentifier() -> String
    func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize
}

public protocol PageView {
    func configure(data: Content, pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool)
    func resize(pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool)
    func resize()
}

open class _PageContent: NSObject, Content {
    public enum PresentationType {
        case `class`(AnyClass)
        case nib(UINib, AnyClass)
    }

    private var _type: PresentationType
    public var type: PresentationType {
        _type
    }

    public init(type: PresentationType) {
        _type = type
    }

    @objc open func isPreloadable() -> Bool {
        false
    }

    @objc open func isPreloading() -> Bool {
        false
    }

    @objc open func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    @objc open func preload(completion _: ((_PageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    @objc open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    @objc open func reload() {
        reload(completion: nil)
    }

    @objc open func reload(completion _: ((_PageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    @objc open func reuseIdentifier() -> String {
        switch type {
        case let .class(cellClass):
            return "\(cellClass.self)"
        case let .nib(_, cellClass):
            return "\(cellClass.self)"
        }
    }

    open func size(inRect rect: CGRect, direction _: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize {
        if traitCollection.isLandscape(), isDoubleSpread {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }

        return rect.size
    }
}
