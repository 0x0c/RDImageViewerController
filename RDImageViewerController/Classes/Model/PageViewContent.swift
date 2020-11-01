//
//  RDPageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

open class PageViewContent: PagingViewLoadable {
    public enum PageViewRepresentation {
        case `class`(AnyClass)
        case nib(UINib, AnyClass)
    }

    public private(set) var type: PageViewRepresentation

    public init(type: PageViewRepresentation) {
        self.type = type
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

    open func preload(completion _: ((PagingViewLoadable) -> Void)?) {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func stopPreload() {
        NSException(name: NSExceptionName(rawValue: "RDPageContentData"), reason: "You have to override this method. \(#function)", userInfo: nil).raise()
    }

    open func reload() {
        reload(completion: nil)
    }

    open func reload(completion _: ((PagingViewLoadable) -> Void)?) {
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
        if RDImageViewerController.rd_isLandscape(), isDoubleSpread {
            return CGSize(width: rect.width / 2.0, height: rect.height)
        }

        return rect.size
    }
}
