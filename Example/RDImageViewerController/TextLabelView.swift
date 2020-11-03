//
//  TextLabelView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class TextLabelView: UICollectionViewCell, PageViewRepresentation {
    @IBOutlet var label: UILabel!

    func configure(data: PagingViewLoadable, pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {
        guard let data = data as? TextContent else {
            return
        }
        label.text = data.text
    }

    func resize(pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {}

    func resize() {}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.text = ""
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.darkGray.cgColor
    }
}
