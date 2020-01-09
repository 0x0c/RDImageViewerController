//
//  TextLabelView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class TextLabelView: UICollectionViewCell, RDPageViewProtocol {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(data: RDPageContentProtocol, pageIndex: Int, traitCollection: UITraitCollection, doubleSided: Bool) {
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
    }
    
}
