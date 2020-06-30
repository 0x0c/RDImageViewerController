//
//  UIView+PageIndex.swift
//  Pods
//
//  Created by Akira Matsuda on 2020/07/01.
//

import UIKit

extension UIView {
    static var pageIndexKey: UInt8 = 0
    var _pageIndex: Int {
        get {
            guard let associatedObject = objc_getAssociatedObject(self, &UIView.pageIndexKey) as? NSNumber else {
                let associatedObject = NSNumber(value: Int(0))
                objc_setAssociatedObject(self, &UIView.pageIndexKey, associatedObject, .OBJC_ASSOCIATION_RETAIN)
                return Int(associatedObject.intValue)
            }
            return Int(associatedObject.intValue)
        }

        set {
            objc_setAssociatedObject(self, &UIView.pageIndexKey, NSNumber(value: Int(newValue)), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var pageIndex: Int {
        _pageIndex
    }
}
