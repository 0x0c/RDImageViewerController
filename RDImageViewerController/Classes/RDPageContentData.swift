//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol RDPageContentProtocol {
    func isPreloadable() -> Bool
    func preload()
    func preload(completion: ((RDPageContentData) -> Void)?)
    func stopPreload()
    func reload()
    func reload(completion: ((RDPageContentData) -> Void)?)
    func reuseIdentifier() -> String
    func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize
}

public protocol RDPageContentDataViewProtocol {
    func configure(data: RDPageContentProtocol)
    func resize()
}

open class RDPageContentData: NSObject, RDPageContentProtocol {
    
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

    @objc open func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func preload(completion: ((RDPageContentData) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }
    
    @objc open func reload() {
        reload(completion: nil)
    }
    
    @objc open func reload(completion: ((RDPageContentData) -> Void)?) {
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
    
    open func size(inRect rect: CGRect, direction: RDPagingView.ForwardDirection) -> CGSize {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
        return CGSize.zero
    }

}
