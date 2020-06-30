//
//  UISlider+Position.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

extension UISlider {
    public func trueSliderValue(value: Float, pagingView: PagingView) -> Float {
        pagingView.scrollDirection == .right ? value : 1 - value
    }

    public func setTrueSliderValue(value: Float, pagingView: PagingView, animated: Bool = false) {
        let position = trueSliderValue(value: value, pagingView: pagingView)
        setValue(position, animated: animated)
    }
}
