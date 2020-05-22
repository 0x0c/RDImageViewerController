//
//  SliderBehaviour.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

public protocol SliderBehaviour {
    func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView)
    func snapSliderPosition(slider: UISlider, pagingView: PagingView)
}
