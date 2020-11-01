//
//  DoubleImagePagingBehavior.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/11/02.
//

import Foundation

open class DoubleImagePagingBehavior: SinglePagingBehavior {
    open override func updateLabel(label: UILabel, numerator: PagingView.VisibleIndex, denominator: Int) {
        switch numerator {
        case let .single(index):
            label.text = "[\(index + 1)-\(index + 2)]/\(denominator * 2)"
        default:
            break
        }
    }
}
