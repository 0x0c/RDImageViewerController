//
//  ForwardDirection+Orientation.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/07/01.
//

extension PagingView.ForwardDirection {
    public func isHorizontal() -> Bool {
        self == .left || self == .right
    }

    public func isVertical() -> Bool {
        self == .up || self == .down
    }
}
