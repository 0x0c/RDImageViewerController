//
//  SinglePagingBehavior.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

open class SinglePagingBehavior: HudBehavior, SliderBehavior, PagingBehavior {
    public init() {}

    open func updateLabel(label: UILabel, numerator: PagingView.VisibleIndex, denominator: Int) {
        switch numerator {
        case let .single(index):
            label.text = "\(index + 1)/\(denominator)"
        case let .double(indexes):
            if let index = indexes.min() {
                label.text = "\(index + 1)/\(denominator)"
            }
        }
    }

    open func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView) {
        let position = value / Float(pagingView.numberOfPages - 1)
        slider.rd_setTrueSliderValue(value: Float(position), pagingView: pagingView)
    }

    open func snapSliderPosition(slider: UISlider, pagingView: PagingView) {
        if pagingView.scrollDirection.isVertical {
            return
        }
        let value = Float(pagingView.currentPageIndex.primaryIndex()) / Float(pagingView.numberOfPages - 1)
        slider.rd_setTrueSliderValue(value: value, pagingView: pagingView)
    }

    open func updatePageIndex(_ index: Int, pagingView: PagingView) {
        pagingView.currentPageIndex = index.rd_single()
    }
}
