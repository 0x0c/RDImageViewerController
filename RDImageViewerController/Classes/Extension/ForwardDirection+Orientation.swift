//
//  ForwardDirection+Orientation.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/07/01.
//

extension PagingView.ForwardDirection {
    public var isHorizontal: Bool {
        self == .left || self == .right
    }

    public var isVertical: Bool {
        self == .up || self == .down
    }
}
