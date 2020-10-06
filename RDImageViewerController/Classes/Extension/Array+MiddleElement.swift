//
//  Array+MiddleElement.swift
//  Pods
//
//  Created by Akira Matsuda on 2020/07/01.
//

extension Array {
    var rd_middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }
}
