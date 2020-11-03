//
//  DoubleSpreadConfiguration.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

public protocol Configuration {
    func interfaceBehavior(isDoubleSpread: Bool) -> InterfaceBehavior
    func filter(_ originalContents: [PageViewContent], isLandscape: Bool) -> [PageViewContent]
    var hasDifferentContentsForOrientation: Bool { get }
    var portrait: Bool { get set }
    var landscape: Bool { get set }
}

open class DoubleSpreadConfiguration: Configuration {
    public var portrait: Bool = false
    public var landscape: Bool = false

    open var hasDifferentContentsForOrientation: Bool {
        false
    }

    public init(portrait: Bool, landscape: Bool) {
        self.portrait = portrait
        self.landscape = landscape
    }

    open func interfaceBehavior(isDoubleSpread: Bool) -> InterfaceBehavior {
        if isDoubleSpread {
            return DoubleSpreadPagingBehavior()
        }
        return SinglePagingBehavior()
    }

    open func filter(_ originalContents: [PageViewContent], isLandscape: Bool) -> [PageViewContent] {
        return originalContents
    }
}
