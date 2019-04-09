//
//  RDPagingViewRightToLeftFlowLayout.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

class RDPagingViewRightToLeftFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
    
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return .rightToLeft
    }

}
