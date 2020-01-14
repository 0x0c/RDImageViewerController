//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

extension UITraitCollection {
    public func isLandscape() -> Bool {
        let portrait = UITraitCollection(traitsFrom: [
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .regular)])
        if containsTraits(in: portrait) {
            return false
        }
        return true
    }
}

public enum ImageHorizontalAlignment {
    case left
    case right
    case center
}

public enum ImageVerticalAlignment {
    case top
    case bottom
    case center
}

public struct ImageAlignment {
    public var horizontal: ImageHorizontalAlignment = .center
    public var vertical: ImageVerticalAlignment = .center
}

public protocol PageContentProtocol {
    func isPreloadable() -> Bool
    func isPreloading() -> Bool
    func preload()
    func preload(completion: ((PageContent) -> Void)?)
    func stopPreload()
    func reload()
    func reload(completion: ((PageContent) -> Void)?)
    func reuseIdentifier() -> String
    func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize
}

public protocol PageViewProtocol {
    func configure(data: PageContentProtocol, pageIndex: Int, traitCollection: UITraitCollection, isDoubleSpread: Bool)
    func resize()
}

open class PageContent: NSObject, PageContentProtocol {
    
    public enum PresentationType {
        case `class`(AnyClass)
        case nib(UINib, AnyClass)
    }
    
    private var _type: PresentationType
    public var type: PresentationType {
        get {
            return _type
        }
    }
    public init(type: PresentationType) {
        self._type = type
    }
        
    @objc open func isPreloadable() -> Bool {
        return false
    }
    
    @objc open func isPreloading() -> Bool {
        return false
    }

    @objc open func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func preload(completion: ((PageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func reload() {
        reload(completion: nil)
    }
    
    @objc open func reload(completion: ((PageContent) -> Void)?) {
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
    
    open func size(inRect rect: CGRect, direction: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize {
        if traitCollection.isLandscape(), isDoubleSpread {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }
        
        return rect.size
    }

}
