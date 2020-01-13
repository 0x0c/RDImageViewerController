//
//  TextLabelView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class TextLabelView: UICollectionViewCell, PageViewProtocol {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(data: PageContentProtocol, pageIndex: Int, traitCollection: UITraitCollection, doubleSided: Bool) {
        guard let data = data as? TextContent else {
            return
        }
        label.text = data.text
    }
    
    func resize() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.text = ""
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
}
