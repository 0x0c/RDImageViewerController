//
//  DoubleSpreadConfiguration.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

public struct DoubleSpreadConfiguration {
    public var portrait: Bool = false
    public var landscape: Bool = false

    public init(portrait: Bool, landscape: Bool) {
        self.portrait = portrait
        self.landscape = landscape
    }
}
