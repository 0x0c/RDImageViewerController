//
//  UIView+PageIndex.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/19.
//

extension UIView
{
    static var pageIndexKey: UInt8 = 0
    public var pageIndex: Int {
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
}
