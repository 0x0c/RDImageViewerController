//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol RDPageContentDataDelegate {
    func isPreloadable() -> Bool
    func preload()
    func stopPreload()
    func reload()
    func reuseIdentifier() -> String
    func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize
}

@objc public protocol RDPageContentDataView {
    func configure(data: RDPageContentData)
    func resize()
}

open class RDPageContentData: NSObject, RDPageContentDataDelegate {
    
    public enum PresentationType {
        case `class`(AnyClass)
        case nib(UINib)
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

    @objc open func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    @objc open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    @objc open func reload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    @objc open func reuseIdentifier() -> String {
        return ""
    }
    
    open func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
        return CGSize.zero
    }

}
