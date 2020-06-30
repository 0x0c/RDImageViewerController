//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

open class Content: PageContent {
    public enum PresentationType {
        case `class`(AnyClass)
        case nib(UINib, AnyClass)
    }

    private var _type: PresentationType
    public var type: PresentationType {
        _type
    }

    public init(type: PresentationType) {
        _type = type
    }

    open func isPreloadable() -> Bool {
        false
    }

    open func isPreloading() -> Bool {
        false
    }

    open func preload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func preload(completion _: ((PageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func reload() {
        reload(completion: nil)
    }

    open func reload(completion _: ((PageContent) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func reuseIdentifier() -> String {
        switch type {
        case let .class(cellClass):
            return "\(cellClass.self)"
        case let .nib(_, cellClass):
            return "\(cellClass.self)"
        }
    }

    open func size(inRect rect: CGRect, direction _: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) -> CGSize {
        if traitCollection.isLandscape(), isDoubleSpread {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }

        return rect.size
    }
}
