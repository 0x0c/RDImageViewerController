//
//  UITraitCollection+Orientation.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/01/22.
//

import Foundation

extension UIApplication {
    public func currentWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
        }
        else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension UITraitCollection {
    public func isLandscape() -> Bool {
        if userInterfaceIdiom == .phone {
            let portrait = UITraitCollection(traitsFrom: [
                UITraitCollection(horizontalSizeClass: .compact),
                UITraitCollection(verticalSizeClass: .regular)])
            if containsTraits(in: portrait) {
                return false
            }
            return true
        }
        else {
            if #available(iOS 13, *)  {
                if let window = UIApplication.shared.currentWindow(),
                    let windowScene = window.windowScene {
                    return windowScene.interfaceOrientation.isLandscape
                }
                return false
            }
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
