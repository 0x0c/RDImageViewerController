//
//  DoubleSpreadPagingBehavior.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

open class DoubleSpreadPagingBehavior: HudBehavior, SliderBehavior, PagingBehavior {
    public init() {}

    open func updateLabel(label: UILabel, numerator: PagingView.VisibleIndex, denominator: Int) {
        switch numerator {
        case let .double(indexes):
            var pageString = indexes.sorted().map { (index) -> String in
                String(index + 1)
            }.joined(separator: " - ")
            if indexes.count > 1 {
                pageString = "[" + pageString + "]"
            }
            label.text = "\(pageString)/\(denominator)"
        default:
            break
        }
    }

    open func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView) {
        let snapPosition = (value - 0.5) * 2
        if pagingView.numberOfPages % 2 == 1 {
            UIView.animate(withDuration: 0.1) {
                if snapPosition > Float(pagingView.numberOfPages - 4) {
                    let position = value * 2 / Float(pagingView.numberOfPages - 2)
                    slider.setTrueSliderValue(value: position, pagingView: pagingView, animated: true)
                }
                else {
                    let position = value * 2 / Float(pagingView.numberOfPages - 1)
                    slider.setTrueSliderValue(value: Float(position), pagingView: pagingView, animated: true)
                }
            }
        }
        else {
            let position = value * 2 / Float(pagingView.numberOfPages - 2)
            slider.setTrueSliderValue(value: Float(position), pagingView: pagingView)
        }
    }

    open func snapSliderPosition(slider: UISlider, pagingView: PagingView) {
        if pagingView.scrollDirection.isVertical() {
            return
        }
        if case let .double(indexes) = pagingView.currentPageIndex, indexes.count > 0 {
            if pagingView.numberOfPages % 2 == 1 {
                let index = indexes.sorted().first!
                let value = Float(index + index % 2) / Float(pagingView.numberOfPages - 1)
                slider.setTrueSliderValue(value: value, pagingView: pagingView)
            }
            else {
                let index = indexes.sorted().first!
                let value = Float(index + index % 2) / Float(pagingView.numberOfPages - 2)
                slider.setTrueSliderValue(value: value, pagingView: pagingView)
            }
        }
    }

    open func updatePageIndex(_ index: Int, pagingView: PagingView) {
        if index % 2 == 0 {
            pagingView.currentPageIndex = index.doubleSpread()
        }
        else {
            pagingView.currentPageIndex = (index - 1).doubleSpread()
        }
    }
}
