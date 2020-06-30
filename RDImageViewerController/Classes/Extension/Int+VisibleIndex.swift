//
//  Int+VisibleIndex.swift
//  Pods
//
//  Created by Akira Matsuda on 2020/07/01.
//

public extension Int {
    func convert(double: Bool) -> PagingView.VisibleIndex {
        if double {
            return .double(indexes: [self])
        }
        return .single(index: self)
    }

    func single() -> PagingView.VisibleIndex {
        .single(index: self)
    }

    func doubleSpread() -> PagingView.VisibleIndex {
        .double(indexes: [self])
    }
}
