//
//  PageView.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/07/01.
//

public protocol PageView {
    func configure(
        data: PagingViewLoadable,
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    )
    func resize(
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    )
    func resize()
}
