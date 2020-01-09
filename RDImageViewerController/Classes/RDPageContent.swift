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

public protocol RDPageContentProtocol {
    func isPreloadable() -> Bool
    func isPreloading() -> Bool
    func preload()
    func preload(completion: ((RDPageContent) -> Void)?)
    func stopPreload()
    func reload()
    func reload(completion: ((RDPageContent) -> Void)?)
    func reuseIdentifier() -> String
    func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection, traitCollection: UITraitCollection, doubleSided: Bool) -> CGSize
}

public protocol RDPageViewProtocol {
    func configure(data: RDPageContentProtocol, pageIndex: Int, traitCollection: UITraitCollection, doubleSided: Bool)
    func resize()
}

open class RDPageContent: NSObject, RDPageContentProtocol {
    
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
    
    @objc open func preload(completion: ((RDPageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func reload() {
        reload(completion: nil)
    }
    
    @objc open func reload(completion: ((RDPageContent) -> Void)?) {
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
    
    open func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection, traitCollection: UITraitCollection, doubleSided: Bool) -> CGSize {
        if traitCollection.isLandscape(), doubleSided {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }
        
        return rect.size
    }

}
