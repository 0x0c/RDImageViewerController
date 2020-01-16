//
//  PagingViewFlowLayout.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/01/16.
//

import UIKit

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}

class PagingViewFlowLayout: UICollectionViewFlowLayout {
    
    private var previousSizs: CGSize = CGSize.zero
    var page: Float = 0
    
    var isDoubleSpread: Bool = false
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds, oldBounds.equalTo(newBounds) {
            return true
        }
        return false
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        page = Float(ceil(proposedContentOffset.x / collectionView.frame.width))
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        let width = collectionView.frame.width
        return CGPoint(x: CGFloat(page) * width, y: 0)
    }
}
