//
//  DoubleSpreadConfiguration.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

import Foundation

@objcMembers
open class DoubleSpreadConfiguration {
    open var portrait: Bool = false
    open var landscape: Bool = false

    public init(portrait: Bool, landscape: Bool) {
        self.portrait = portrait
        self.landscape = landscape
    }
}
