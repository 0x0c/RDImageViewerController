//
//  RDPagingViewHorizontalFlowLayouts.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

class RDPagingViewHorizontalFlowLayout: UICollectionViewFlowLayout {
    
    var indexPathsToAnimate = [IndexPath]()
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        if let collectionView = collectionView, let attribute = super.layoutAttributesForItem(at: indexPath) {
//            attribute.center = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y)
//            return attribute
//        }
//        return nil
//    }
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return super.layoutAttributesForElements(in: rect)
//    }
//    
//    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        if let collectionView = collectionView, let attribute = self.layoutAttributesForItem(at: itemIndexPath), indexPathsToAnimate.contains(itemIndexPath) {
//            attribute.center = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.maxY)
//            indexPathsToAnimate.remove(at: indexPathsToAnimate.firstIndex(of: itemIndexPath)!)
//            return attribute
//        }
//        
//        return nil
//    }
//    
//    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        return self.layoutAttributesForItem(at: itemIndexPath)
//    }
//    
//    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
//        super.prepare(forCollectionViewUpdates: updateItems)
//        var indexPaths = [IndexPath]()
//        for item in updateItems {
//            switch item.updateAction {
//            case .insert:
//                indexPaths.append(item.indexPathAfterUpdate!)
//            case .delete:
//                indexPaths.append(item.indexPathBeforeUpdate!)
//            case .move:
//                indexPaths.append(item.indexPathBeforeUpdate!)
//                indexPaths.append(item.indexPathAfterUpdate!)
//            case .reload, .none:
//                break
//            @unknown default:
//                break
//            }
//        }
//        return
//    }
}
