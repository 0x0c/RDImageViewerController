//
//  UISlider+Position.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

import UIKit

extension UISlider {
    public func rd_trueSliderValue(value: Float, pagingView: PagingView) -> Float {
        pagingView.scrollDirection == .right ? value : 1 - value
    }

    public func rd_setTrueSliderValue(value: Float, pagingView: PagingView, animated: Bool = false) {
        let position = rd_trueSliderValue(value: value, pagingView: pagingView)
        setValue(position, animated: animated)
    }
}
