//
//  RDPagingView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

@objc public protocol RDPagingViewDataSource {
    func pagingView(pagingView: RDPagingView, preloadItemAt index: Int)
    func pagingView(pagingView: RDPagingView, cancelPreloadingItemAt index: Int)
}

@objc public protocol RDPagingViewDelegate {
    @objc optional func pagingView(pagingView: RDPagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView])
    @objc optional func pagingView(pagingView: RDPagingView, willChangeIndexTo index: Int)
    @objc optional func pagingView(pagingView: RDPagingView, didsChangeIndexTo index: Int)
    @objc optional func pagingView(pagingView: RDPagingView, didScrollToPosition position: CGFloat)
    @objc optional func pagingViewWillBeginDragging(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndDragging(pagingView: RDPagingView, willDecelerate decelerate: Bool)
    @objc optional func pagingViewWillBeginDecelerating(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndDecelerating(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndScrollingAnimation(pagingView: RDPagingView)
}

open class RDPagingView: UICollectionView {
    
    public enum ForwardDirection {
        case right
        case left
        case up
        case down
        
        public func isHorizontal() -> Bool {
            return self == .left || self == .right
        }
    }
    
    public enum MovingDirection {
        case forward
        case backward
        case unknown
    }
    
    public var pagingDataSource: (RDPagingViewDataSource & UICollectionViewDataSource)?
    public var pagingDelegate: (RDPagingViewDelegate & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout)?
    public let direction: ForwardDirection
    
    private var previousIndex: Int = 0
    var numberOfPages = 0
    private var _currentPageIndex: Int = 0
    public var currentPageIndex: Int {
        set {
            if newValue >= 0, newValue < numberOfPages {
                scrollTo(index: newValue)
                _currentPageIndex = newValue
            }
        }
        get {
            if isLegacyLayoutSystem {
                return numberOfPages - _currentPageIndex - 1
            }
            return _currentPageIndex
        }
    }
    
    public var preloadCount: Int = 3
    
    var isLegacyLayoutSystem: Bool {
        get {
            return semanticContentAttribute == .forceRightToLeft
        }
    }
    
    public init(frame: CGRect, forwardDirection: ForwardDirection) {
        self.direction = forwardDirection
        if forwardDirection == .left {
            super.init(frame: frame, collectionViewLayout: RDPagingViewRightToLeftFlowLayout())
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            }
            else {
                self.semanticContentAttribute = .forceRightToLeft
                _currentPageIndex = numberOfPages
            }
        }
        else if forwardDirection == .right {
            super.init(frame: frame, collectionViewLayout: RDPagingViewHorizontalFlowLayout())
        }
        else if forwardDirection == .up {
            super.init(frame: frame, collectionViewLayout: RDPagingViewBottomToTopLayout())
        }
        else { // .down
            super.init(frame: frame, collectionViewLayout: RDPagingViewVerticalFlowLayout())
        }
        
        self.delegate = self
        self.dataSource = self
        self.prefetchDataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startRotation() {
        previousIndex = currentPageIndex
    }
    
    public func endRotation() {
        scrollTo(index: previousIndex)
    }
    
    public func scrollTo(index: Int) {
        scrollToItem(at: IndexPath(row: index, section: 0), at: direction.isHorizontal() ? .centeredHorizontally : .centeredVertically, animated: false)
    }
    
    public func resize() {
        collectionViewLayout.invalidateLayout()
        reloadItems(at: indexPathsForVisibleItems)
    }
    
    open override func reloadData() {
        guard let pagingDataSource = pagingDataSource else {
            return
        }
        numberOfPages = pagingDataSource.collectionView(self, numberOfItemsInSection: 0)
        super.reloadData()
    }
}

extension RDPagingView : UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var position: CGFloat
        if direction.isHorizontal() {
            position = scrollView.contentOffset.x / scrollView.frame.width
        }
        else {
            position = scrollView.contentOffset.y / scrollView.frame.height
        }
        
        let to = Int(position + 0.5)
        if let pagingDelegate = pagingDelegate {
            if previousIndex != to {
                if isLegacyLayoutSystem {
                    pagingDelegate.pagingView?(pagingView: self, willChangeIndexTo: numberOfPages - to - 1)
                }
                else {
                    pagingDelegate.pagingView?(pagingView: self, willChangeIndexTo: to)
                }
            }
            pagingDelegate.pagingView?(pagingView: self, didScrollToPosition: position)
        }
        _currentPageIndex = to
        if previousIndex != to {
            previousIndex = to
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDragging?(pagingView: self)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDragging?(pagingView: self, willDecelerate: decelerate)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDecelerating?(pagingView: self)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDecelerating?(pagingView: self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndScrollingAnimation?(pagingView: self)
        }
    }
}

extension RDPagingView : UICollectionViewDataSourcePrefetching
{
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let pagingDataSource = pagingDataSource else {
            return
        }
        if let lastIndexPath = indexPaths.last, let firstIndexPath = indexPaths.first {
            let startIndex = max(0, firstIndexPath.row - preloadCount)
            let endIndex = min(numberOfPages - 1, lastIndexPath.row + preloadCount)
            for i in startIndex..<endIndex {
                pagingDataSource.pagingView(pagingView: self, preloadItemAt: i)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let pagingDataSource = pagingDataSource, numberOfPages > 0 else {
            return
        }
        if let lastIndexPath = indexPaths.last, let firstIndexPath = indexPaths.first {
            let startIndex = min(max(0, firstIndexPath.row - preloadCount), numberOfPages - 1)
            let endIndex = max(min(numberOfPages - 1, lastIndexPath.row + preloadCount), 0)
            
            for i in startIndex..<endIndex {
                pagingDataSource.pagingView(pagingView: self, cancelPreloadingItemAt: i)
            }
        }
    }
}

extension RDPagingView : UICollectionViewDelegate
{
    
}

extension RDPagingView : UICollectionViewDataSource
{
    open override func numberOfItems(inSection section: Int) -> Int {
        guard let pagingDataSource = pagingDataSource else {
            return 0
        }
        return pagingDataSource.collectionView(self, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pagingDataSource = pagingDataSource else {
            numberOfPages = 0
            return numberOfPages
        }
        numberOfPages = pagingDataSource.collectionView(collectionView, numberOfItemsInSection: section)
        return numberOfPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pagingDataSource = pagingDataSource else {
            return UICollectionViewCell(frame: CGRect.zero)
        }
        return pagingDataSource.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

extension RDPagingView : UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let pagingDelegate = pagingDelegate else {
            return CGSize.zero
        }
        return pagingDelegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
    }
}

extension UIView
{
    static var pageIndexKey: UInt8 = 0
    public var pageIndex: Int {
        get {
            guard let associatedObject = objc_getAssociatedObject(self, &UIView.pageIndexKey) as? NSNumber else {
                let associatedObject = NSNumber(value: Int(0))
                objc_setAssociatedObject(self, &UIView.pageIndexKey, associatedObject, .OBJC_ASSOCIATION_RETAIN)
                return Int(associatedObject.intValue)
            }
            return Int(associatedObject.intValue)
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.pageIndexKey, NSNumber(value: Int(newValue)), .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
