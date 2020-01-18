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
    var currentPageIndex: PagingView.VisibleIndex = .single(index: 0)
    var isDoubleSpread: Bool = false
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        var xPosition: CGFloat = 0
        let width = collectionView.frame.width
        switch currentPageIndex {
        case let .single(index):
            xPosition = CGFloat(index) * width
        case let .double(indexes):
            if let index = indexes.sorted().first {
                let trueIndex = index
                xPosition = CGFloat(trueIndex) * width
            }
        }
        if collectionView.contentOffset.x <= xPosition, isDoubleSpread {
            xPosition = collectionView.contentOffset.x
        }
        return CGPoint(x: xPosition, y: 0)
    }
}
