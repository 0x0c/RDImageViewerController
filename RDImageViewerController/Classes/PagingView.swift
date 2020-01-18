//
//  RDPagingView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol PagingViewDataSource {
    func pagingView(pagingView: PagingView, preloadItemAt index: Int)
    func pagingView(pagingView: PagingView, cancelPreloadingItemAt index: Int)
}

extension PagingViewDataSource {
    public func pagingView(pagingView: PagingView, preloadItemAt index: Int) {}
    public func pagingView(pagingView: PagingView, cancelPreloadingItemAt index: Int) {}
}

public protocol PagingViewDelegate {
    func pagingView(pagingView: PagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView])
    func pagingView(pagingView: PagingView, willChangeIndexTo index: Int)
    func pagingView(pagingView: PagingView, didChangeIndexTo index: Int)
    func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat)
    func pagingView(pagingView: PagingView, didEndDisplaying view: UIView & PageViewProtocol, index: Int)
    func pagingViewWillBeginDragging(pagingView: PagingView)
    func pagingViewDidEndDragging(pagingView: PagingView, willDecelerate decelerate: Bool)
    func pagingViewWillBeginDecelerating(pagingView: PagingView)
    func pagingViewDidEndDecelerating(pagingView: PagingView)
    func pagingViewDidEndScrollingAnimation(pagingView: PagingView)
}

extension PagingViewDelegate {
    public func pagingView(pagingView: PagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView]) {}
    public func pagingView(pagingView: PagingView, willChangeIndexTo index: Int) {}
    public func pagingView(pagingView: PagingView, didsChangeIndexTo index: Int) {}
    public func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat) {}
    public func pagingView(pagingView: PagingView, didEndDisplaying view: UIView & PageViewProtocol, index: Int) {}
    public func pagingViewWillBeginDragging(pagingView: PagingView) {}
    public func pagingViewDidEndDragging(pagingView: PagingView, willDecelerate decelerate: Bool) {}
    public func pagingViewWillBeginDecelerating(pagingView: PagingView) {}
    public func pagingViewDidEndDecelerating(pagingView: PagingView) {}
    public func pagingViewDidEndScrollingAnimation(pagingView: PagingView) {}
}

public extension Int {
    func convert(double: Bool) -> PagingView.VisibleIndex {
        if double {
            return .double(indexes: [self])
        }
        return .single(index: self)
    }
    
    func single() -> PagingView.VisibleIndex {
        return .single(index: self)
    }
    
    func doubleSpread() -> PagingView.VisibleIndex {
        return .double(indexes: [self])
    }
}

open class PagingView: UICollectionView {
    
    public enum ForwardDirection {
        case right
        case left
        case up
        case down
        
        public func isHorizontal() -> Bool {
            return self == .left || self == .right
        }
        
        public func isVertical() -> Bool {
            return self == .up || self == .down
        }
    }
    
    public enum MovingDirection {
        case forward
        case backward
        case unknown
    }
    
    public enum VisibleIndex {
        case single(index: Int)
        case double(indexes: [Int])
        
        static func ==(a: VisibleIndex, b: VisibleIndex) -> Bool {
            switch (a, b) {
            case let (.single(index1), .single(index2)):
                return index1 == index2
            case let (.double(indexes1), .double(indexes2)):
                return indexes1 == indexes2
            default:
                return false
            }
        }
        
        static func !=(a: VisibleIndex, b: VisibleIndex) -> Bool {
            switch (a, b) {
            case let (.single(index1), .single(index2)):
                return !(index1 == index2)
            case let (.double(indexes1), .double(indexes2)):
                return !(indexes1 == indexes2)
            default:
                return true
            }
        }
        
        func convert(double: Bool) -> VisibleIndex {
            switch self {
            case let .single(index):
                if double {
                    return .double(indexes: [index])
                }
                return self
            case let .double(indexes):
                if double {
                    return self
                }
                
                if let index = indexes.sorted().first {
                    return .single(index: index)
                }
                return .single(index: 0)
            }
        }
    }
    
    public weak var pagingDataSource: (PagingViewDataSource & UICollectionViewDataSource)?
    public weak var pagingDelegate: (PagingViewDelegate & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout)?
        
    public var numberOfPages = 0
    public var preloadCount: Int = 3
    
    private var _isDoubleSpread: Bool = false
    public var isDoubleSpread: Bool {
        get {
            return _isDoubleSpread
        }
        set {
            _isDoubleSpread = newValue
            currentPageIndex = currentPageIndex.convert(double: newValue)
            if let layout = collectionViewLayout as? PagingViewFlowLayout {
                layout.isDoubleSpread = newValue
            }
        }
    }
    
    public var scrollDirection: ForwardDirection
    
    private var _currentPageIndex: VisibleIndex = .single(index: 0)
    public var currentPageIndex: VisibleIndex {
        set {
            _currentPageIndex = newValue
            switch newValue {
            case let .single(index):
                scrollTo(index: index)
            case let .double(indexes):
                if let index = indexes.sorted().first {
                    scrollTo(index: index)
                }
            }
        }
        get {
            if isDoubleSpread {
                return .double(indexes: visiblePageIndexes)
            }
            
            return _currentPageIndex
        }
    }
    
    public var visiblePageIndexes: [Int] {
        return indexPathsForVisibleItems.map({ (indexPath) -> Int in
            Int(indexPath.row)
        })
    }
    
    public var isLegacyLayoutSystem: Bool {
        get {
            if #available(iOS 11.0, *) {
                return false
            }
            else if scrollDirection == .left {
                return true
            }
            else {
                return false
            }
        }
    }
    
    public init(frame: CGRect, forwardDirection: ForwardDirection) {
        self.scrollDirection = forwardDirection
        if forwardDirection == .left {
            super.init(frame: frame, collectionViewLayout: PagingViewRightToLeftFlowLayout())
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            }
            else {
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        }
        else if forwardDirection == .right {
            super.init(frame: frame, collectionViewLayout: PagingViewHorizontalFlowLayout())
        }
        else if forwardDirection == .up {
            super.init(frame: frame, collectionViewLayout: PagingViewBottomToTopLayout())
        }
        else { // .down
            super.init(frame: frame, collectionViewLayout: PagingViewVerticalFlowLayout())
        }
        
        self.delegate = self
        self.dataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollTo(index: Int, animated: Bool = false) {
        var position: UICollectionView.ScrollPosition {
            if scrollDirection.isHorizontal() {
                if isDoubleSpread {
                    if index % 2 == 0 {
                        return .left
                    }
                    return .right
                }
                return .centeredHorizontally
            }
            else {
                return .centeredVertically
            }
        }
        if let layout = collectionViewLayout as? PagingViewFlowLayout {
            layout.currentPageIndex = currentPageIndex
        }
        scrollToItem(at: IndexPath(row: index, section: 0), at: position, animated: animated)
    }
    
    public func resizeVisiblePages() {
        collectionViewLayout.invalidateLayout()
        for cell in visibleCells {
            if let view = cell as? PageViewProtocol {
                view.resize()
            }
        }
    }
    
    public func changeDirection(_ forwardDirection: ForwardDirection) {
        self.scrollDirection = forwardDirection
        if forwardDirection == .left {
            collectionViewLayout = PagingViewRightToLeftFlowLayout()
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            }
            else {
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        }
        else {
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            if forwardDirection == .right {
                collectionViewLayout = PagingViewHorizontalFlowLayout()
            }
            else if forwardDirection == .up {
                collectionViewLayout = PagingViewBottomToTopLayout()
            }
            else { // .down
                collectionViewLayout = PagingViewVerticalFlowLayout()
            }
        }
        
        reloadItems(at: indexPathsForVisibleItems)
    }
    
    open override func reloadData() {
        guard let pagingDataSource = pagingDataSource else {
            return
        }
        numberOfPages = pagingDataSource.collectionView(self, numberOfItemsInSection: 0)
        super.reloadData()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isLegacyLayoutSystem {
            for cell in visibleCells {
                cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        }
    }
}

extension Array {
    
    var middle: Element? {
        guard count != 0 else { return nil }
        
        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }
    
}

extension PagingView : UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pagingDelegate = pagingDelegate else {
            return
        }
        let position = scrollView.contentOffset.x / scrollView.frame.width
        if scrollDirection.isHorizontal() {
            pagingDelegate.pagingView(pagingView: self, didScrollToPosition: position)
            if isDoubleSpread {
                _currentPageIndex = .double(indexes: visiblePageIndexes)
            }
            else {
                let to = Int(position + 0.5)
                _currentPageIndex = to.single()
            }
        }
        else {
            pagingDelegate.pagingView(pagingView: self, didScrollToPosition: scrollView.contentOffset.y)
            if let index = indexPathsForVisibleItems.sorted().middle {
                let to = index.row
                _currentPageIndex = to.convert(double: isDoubleSpread)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDragging(pagingView: self)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDragging(pagingView: self, willDecelerate: decelerate)
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDecelerating(pagingView: self)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDecelerating(pagingView: self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndScrollingAnimation(pagingView: self)
        }
    }
}

extension PagingView : UICollectionViewDelegate
{

}

extension PagingView : UICollectionViewDataSource
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
        let cell = pagingDataSource.collectionView(collectionView, cellForItemAt: indexPath)
        cell.pageIndex = indexPath.row
        if isLegacyLayoutSystem {
            cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        // prefetch
        let prefetchStartIndex = max(0, indexPath.row - preloadCount)
        let prefetchEndIndex = min(numberOfPages - 1, indexPath.row + preloadCount)
        for i in (prefetchStartIndex..<prefetchEndIndex) {
            pagingDataSource.pagingView(pagingView: self, preloadItemAt: i)
        }
        
        // cancel
        let cancelStartIndex = min(max(0, indexPath.row - preloadCount - 1), numberOfPages - 1)
        let cancelEndIndex = max(min(numberOfPages - 1, indexPath.row + preloadCount + 1), 0)
        for i in cancelStartIndex..<prefetchStartIndex {
            pagingDataSource.pagingView(pagingView: self, cancelPreloadingItemAt: i)
        }
        for i in prefetchEndIndex..<cancelEndIndex {
            pagingDataSource.pagingView(pagingView: self, cancelPreloadingItemAt: i)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pagingDelegate = pagingDelegate else {
            return
        }
        
        pagingDelegate.pagingView(pagingView: self, willChangeIndexTo: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pagingDelegate = pagingDelegate, let view = cell as? (UIView & PageViewProtocol) else {
            return
        }
        
        pagingDelegate.pagingView(pagingView: self, didEndDisplaying: view, index: indexPath.row)
    }
}

extension PagingView : UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let pagingDelegate = pagingDelegate else {
            return CGSize.zero
        }
        return pagingDelegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
    }
}
