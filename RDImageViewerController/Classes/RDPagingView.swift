//
//  RDPagingView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

@objc public protocol RDPagingViewDataSource {
    func pagingView(pagingView: RDPagingView, preloadItemAt index: Int)
}

@objc public protocol RDPagingViewDelegate {
    @objc optional func pagingView(pagingView: RDPagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView])
    @objc optional func pagingView(pagingView: RDPagingView, willChangeIndexTo index: Int)
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
            return self == .right || self == .left
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
    
    var _currentPageIndex: Int = 0
    public var currentPageIndex: Int {
        set {
            if newValue >= 0 {
                if _currentPageIndex - newValue != 0 {
                    
                }
                _currentPageIndex = newValue
            }
        }
        get {
            return _currentPageIndex
        }
    }
    
    public var preloadCount: Int = 3
    
    public init(frame: CGRect, forwardDirection: ForwardDirection) {
        self.direction = forwardDirection
        let layout = UICollectionViewFlowLayout()
        if forwardDirection.isHorizontal() {
            layout.scrollDirection = .horizontal
        }
        else {
            layout.scrollDirection = .vertical
        }
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
//        if #available(iOS 11.0, *) {
//            self.contentInsetAdjustmentBehavior = .automatic
//        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startRotation() {
        delegate = nil
    }
    
    public func endRotation() {
        delegate = self
    }
    
    public func resize(with frame: CGRect, duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.collectionViewLayout.invalidateLayout()
            self.reloadData()
        }
    }
    
    open override func reloadData() {
        guard let pagingDataSource = pagingDataSource else {
            return
        }
        for i in 0..<preloadCount {
            pagingDataSource.pagingView(pagingView: self, preloadItemAt: i)
        }
        super.reloadData()
    }
    
    public func pageIndexWillChange(to: Int) {
        let movingDirection: MovingDirection = to - currentPageIndex > 0 ? .forward : (to - currentPageIndex < 0 ? .backward : .unknown)

        if movingDirection != .unknown {
            preload(numberOfViews: preloadCount, fromIndex: to)
        }
        
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, willChangeIndexTo: to)
        }
    }
    
    public func preload(numberOfViews: Int, fromIndex: Int) {
        let startIndex = max(0, fromIndex - numberOfViews)
        let numberOfPages = numberOfItems(inSection: 0)
        let endIndex = min(numberOfPages, fromIndex + numberOfViews + 1)
        for i in endIndex..<startIndex {
            guard let pagingDataSource = pagingDataSource else {
                return
            }
            pagingDataSource.pagingView(pagingView: self, preloadItemAt: i)
        }
    }
}

extension RDPagingView : UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var position: CGFloat = 0
        if direction.isHorizontal() {
            position = scrollView.contentOffset.x / scrollView.frame.width
        }
        else {
            position = scrollView.contentOffset.y / scrollView.frame.height
        }
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, didScrollToPosition: position)
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
            return 0
        }
        return pagingDataSource.collectionView(collectionView, numberOfItemsInSection: section)
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
