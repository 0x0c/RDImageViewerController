//
//  UIView+PageIndex.swift
//  Pods
//
//  Created by Akira Matsuda on 2020/07/01.
//

import UIKit

extension UIView {
    static var rd_pageIndexKey: UInt8 = 0
    var _rd_pageIndex: Int {
        get {
            guard let associatedObject = objc_getAssociatedObject(self, &UIView.rd_pageIndexKey) as? NSNumber else {
                let associatedObject = NSNumber(value: Int(0))
                objc_setAssociatedObject(self, &UIView.rd_pageIndexKey, associatedObject, .OBJC_ASSOCIATION_RETAIN)
                return Int(associatedObject.intValue)
            }
            return Int(associatedObject.intValue)
        }

        set {
            objc_setAssociatedObject(self, &UIView.rd_pageIndexKey, NSNumber(value: Int(newValue)), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var rd_pageIndex: Int {
        _rd_pageIndex
    }
}
