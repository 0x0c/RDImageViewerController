//
//  UITraitCollection+Orientation.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/01/22.
//

import Foundation
import UIKit

extension UIApplication {
    public func rd_currentWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes.filter { $0.activationState == .foregroundActive }.map { $0 as? UIWindowScene }.compactMap { $0 }.first?.windows.filter { $0.isKeyWindow }.first
        }
        else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension RDImageViewerController {
    public static func rd_isLandscape() -> Bool {
        if #available(iOS 13, *) {
            if let window = UIApplication.shared.rd_currentWindow(),
                let windowScene = window.windowScene {
                return windowScene.interfaceOrientation.isLandscape
            }
            return false
        }
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
}
