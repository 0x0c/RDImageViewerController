//
//  DoubleImagePagingBehavior.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/11/02.
//

import Foundation
import UIKit

open class DoubleImagePagingBehavior: SinglePagingBehavior {
    override open func updateLabel(label: UILabel, numerator: PagingView.VisibleIndex, denominator: Int) {
        switch numerator {
        case let .single(index):
            label.text = "[\(index + 1)-\(index + 2)]/\(denominator * 2)"
        default:
            break
        }
    }
}
