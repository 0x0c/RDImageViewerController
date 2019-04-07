//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

protocol RDPageContentDataDelegate {
    func contentView(frame: CGRect) -> UIView
    func preloadable() -> Bool
    func preload()
    func stopPreload()
    func reload()
    func configure(view: UIView)
}

class RDPageContentData: NSObject, RDPageContentDataDelegate {
    
    func contentView(frame: CGRect) -> UIView {
        return UIView(frame: CGRect.zero)
    }
    
    func preloadable() -> Bool {
        return false
    }

    func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    func reload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }
    
    func configure(view: UIView) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method.", userInfo: nil).raise()
    }

}
