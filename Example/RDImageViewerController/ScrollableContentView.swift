//
//  ScrollContentView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class ScrollableContentView: UICollectionViewCell, PageViewRepresentation {
    @IBOutlet var scrollView: UIScrollView!
    var view: UIView?

    func configure(data: PagingViewLoadable, pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {
        guard let data = data as? ScrollableContent else {
            return
        }
        if view == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
            scrollView.addSubview(view!)
            scrollView.contentSize = view!.frame.size
        }
        view!.backgroundColor = data.color
    }

    func resize(pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {}

    func resize() {}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
