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
    var _currentPageIndex: Int = 0
    var currentPageIndex: Int {
        get {
            return _currentPageIndex
        }
        set {
            _currentPageIndex = newValue
        }
    }
    
    var isDoubleSpread: Bool = false
    
//    override func prepare() {
//        super.prepare()
//
//        guard let collectionView = collectionView, collectionView.frame.width > 0 else {
//            return
//        }
//
//        print(collectionView.contentOffset.x / collectionView.frame.width)
//        currentPageIndex = Int(collectionView.contentOffset.x / collectionView.frame.width)
//        if isDoubleSpread == true {
//            currentPageIndex = currentPageIndex - (currentPageIndex % 2)
//        }
////        print("prepare \(collectionView.contentOffset) - \(collectionView.frame.size) -> \(currentPageIndex) double: \(isDoubleSpread)")
//    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        currentPageIndex = Int(ceil(proposedContentOffset.x / collectionView.frame.width))
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
//        let index = Int(collectionView.contentOffset.x / collectionView.frame.width)
//        print("current \(index)")
//        if isDoubleSpread {
//            let truePageIndex = currentPageIndex
//            print("\(truePageIndex) - \(CGPoint(x: CGFloat(truePageIndex) * collectionView.frame.width, y: 0)) - \(collectionView.frame.width)")
//        }
        
        return CGPoint(x: CGFloat(currentPageIndex) * collectionView.frame.width, y: 0)
    }
}
