//
//  RDPagingViewBottomToTopLayout.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/09.
//

import UIKit

class PagingViewBottomToTopLayout: PagingViewVerticalFlowLayout {
    
    open var expandContentSizeToBounds: Bool = true
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = collectionView, expandContentSizeToBounds == true, fabsf(Float(collectionView.bounds.height - newBounds.height)) > .ulpOfOne {
            return true
        }
        
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    override var collectionViewContentSize: CGSize {
        if let collectionView = collectionView, expandContentSizeToBounds {
            let cvContentSize = super.collectionViewContentSize
            let cvBounds = collectionView.bounds.self
            let width = cvContentSize.width
            let height = max(cvContentSize.height, cvBounds.height)
            return CGSize(width: width, height: height)
        }
        
        return super.collectionViewContentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attribute = super.layoutAttributesForItem(at: indexPath) {
            return modifyAttribute(attribute: attribute)
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let newRect = normalRect(forReversedRect: rect)
        if let attributes = super.layoutAttributesForElements(in: newRect) {
            var newAttributes = [UICollectionViewLayoutAttributes]()
            for attr in attributes {
                newAttributes.append(modifyAttribute(attribute: attr))
            }
            
            return newAttributes
        }
        return nil
    }
    
    func modifyAttribute(attribute: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes{
        let normalCenter = attribute.center
        let reversedCenter = reversedPoint(forNormalPoint: normalCenter)
        let newAttribute = attribute
        newAttribute.center = reversedCenter
        return newAttribute
    }

    override var scrollDirection: UICollectionView.ScrollDirection {
        set {
            assert(newValue == .vertical, "horizontal scrolling is not supported")
            super.scrollDirection = newValue
        }
        get {
            return super.scrollDirection
        }
    }
    
    func reversedRect(forNormalRect normalRect: CGRect) -> CGRect {
        let size = normalRect.size
        let normalTopLeft = normalRect.origin
        let reversedBottomLeft = reversedPoint(forNormalPoint: normalTopLeft)
        let reversedTopLeft = CGPoint(x: reversedBottomLeft.x, y: reversedBottomLeft.y - size.height)
        return CGRect(x: reversedTopLeft.x, y: reversedTopLeft.y, width: size.width, height: size.height)
    }
    
    func normalRect(forReversedRect rect: CGRect) -> CGRect {
        return reversedRect(forNormalRect: rect)
    }
    
    func reversedPoint(forNormalPoint normalPoint: CGPoint) -> CGPoint {
        return CGPoint(x: normalPoint.x, y: reversedY(forNormalY: normalPoint.y))
    }
    
    func normalPoint(forReversedPoint point: CGPoint) -> CGPoint {
        return reversedPoint(forNormalPoint: point)
    }
    
    func reversedY(forNormalY normalY: CGFloat) -> CGFloat {
        return CGFloat(collectionViewContentSize.height - normalY)
    }
    
    func normalY(forReversedY y: CGFloat) -> CFloat {
        return CFloat(reversedY(forNormalY: y))
    }
}
