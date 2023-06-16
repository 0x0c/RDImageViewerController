//
//  PagingViewLoadable.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/07/01.
//

import CoreGraphics
import UIKit

public protocol PagingViewLoadable {
    func isPreloadable() -> Bool
    func isPreloading() -> Bool
    func preload()
    func preload(completion: ((PagingViewLoadable) -> Void)?)
    func stopPreload()
    func reload()
    func reload(completion: ((PagingViewLoadable) -> Void)?)
    func reuseIdentifier() -> String
    func size(
        inRect rect: CGRect,
        direction: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) -> CGSize
}
