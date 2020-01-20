//
//  PagingViewFlowLayout.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/01/16.
//

import UIKit

class PagingViewFlowLayout: UICollectionViewFlowLayout {
    private var previousSizs: CGSize = CGSize.zero
    var currentPageIndex: PagingView.VisibleIndex = .single(index: 0)
    var isDoubleSpread: Bool = false
    var ignoreTargetContentOffset = false
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if ignoreTargetContentOffset {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        let width = collectionView.frame.width
        var xPosition = CGFloat(currentPageIndex.primaryIndex()) * width
        if collectionView.contentOffset.x <= xPosition, isDoubleSpread {
            xPosition = collectionView.contentOffset.x
        }
        return CGPoint(x: xPosition, y: 0)
    }
}
