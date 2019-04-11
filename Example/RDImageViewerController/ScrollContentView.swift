//
//  ScrollContentView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class ScrollContentView: UICollectionViewCell, RDPageContentDataViewProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var view: UIView?
    
    func configure(data: RDPageContentProtocol) {
        guard let data = data as? ScrollContentData else {
            return
        }
        if view == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
            scrollView.addSubview(view!)
            scrollView.contentSize = view!.frame.size
        }
        view!.backgroundColor = data.color
    }
    
    func resize() {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
