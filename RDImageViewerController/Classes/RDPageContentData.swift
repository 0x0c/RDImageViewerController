//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol RDPageContentDataDelegate {
    func contentView(frame: CGRect) -> UIView
    func preloadable() -> Bool
    func preload()
    func stopPreload()
    func reload()
    func configure(view: UIView)
}

open class RDPageContentData: NSObject, RDPageContentDataDelegate {
    
    @objc open func contentView(frame: CGRect) -> UIView {
        return UIView(frame: CGRect.zero)
    }
    
    @objc open func preloadable() -> Bool {
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
    
    @objc open func configure(view: UIView) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }

}
