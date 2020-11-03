//
//  PagingBehavior.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

public protocol PagingBehavior {
    func updatePageIndex(_ index: Int, pagingView: PagingView)
}
