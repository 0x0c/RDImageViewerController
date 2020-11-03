//
//  HudBehavior.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/05/22.
//

public protocol HudBehavior {
    func updateLabel(label: UILabel, numerator: PagingView.VisibleIndex, denominator: Int)
}
