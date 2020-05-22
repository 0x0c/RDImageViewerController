//
//  RDPagingView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

extension UIView {
    static var pageIndexKey: UInt8 = 0
    fileprivate var _pageIndex: Int {
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

    public var pageIndex: Int {
        return _pageIndex
    }
}

public protocol PagingViewDataSource {
    func pagingView(pagingView: PagingView, preloadItemAt index: Int)
    func pagingView(pagingView: PagingView, cancelPreloadingItemAt index: Int)
}

public protocol PagingViewDelegate {
    func pagingView(pagingView: PagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView])
    func pagingView(pagingView: PagingView, willChangeIndexTo index: PagingView.VisibleIndex, currentIndex: PagingView.VisibleIndex)
    func pagingView(pagingView: PagingView, didChangeIndexTo index: PagingView.VisibleIndex)
    func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat)
    func pagingView(pagingView: PagingView, didEndDisplaying view: UIView & PageViewProtocol, index: Int)
    func pagingViewWillBeginDragging(pagingView: PagingView)
    func pagingViewDidEndDragging(pagingView: PagingView, willDecelerate decelerate: Bool)
    func pagingViewWillBeginDecelerating(pagingView: PagingView)
    func pagingViewDidEndDecelerating(pagingView: PagingView)
    func pagingViewDidEndScrollingAnimation(pagingView: PagingView)
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

        public static func == (a: VisibleIndex, b: VisibleIndex) -> Bool {
            switch (a, b) {
            case let (.single(index1), .single(index2)):
                return index1 == index2
            case let (.double(indexes1), .double(indexes2)):
                return indexes1 == indexes2
            default:
                return false
            }
        }

        public static func != (a: VisibleIndex, b: VisibleIndex) -> Bool {
            switch (a, b) {
            case let (.single(index1), .single(index2)):
                return !(index1 == index2)
            case let (.double(indexes1), .double(indexes2)):
                return !(indexes1 == indexes2)
            default:
                return true
            }
        }

        public func contains(_ index: VisibleIndex) -> Bool {
            switch (self, index) {
            case let (.single(index1), .single(index2)):
                return (index1 == index2)
            case let (.single(index1), .double(index2)):
                if index2.count == 1, let index = index2.first {
                    return index1 == index
                }
                return false
            case let (.double(index1), .single(index2)):
                return index1.contains(index2)
            case let (.double(indexes1), .double(indexes2)):
                var result = true
                for i in indexes2 {
                    result = result && indexes1.contains(i)
                }
                return result
            }
        }

        public func convert(double: Bool) -> VisibleIndex {
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

        public func primaryIndex() -> Int {
            switch self {
            case let .single(index):
                return index
            case let .double(indexes):
                if let index = indexes.sorted().first {
                    return index
                }
                return -1
            }
        }
    }

    public weak var pagingDataSource: (PagingViewDataSource & UICollectionViewDataSource)?
    public weak var pagingDelegate: (PagingViewDelegate & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout)?

    public var numberOfPages: Int {
        guard let pagingDataSource = pagingDataSource else {
            return 0
        }
        return pagingDataSource.collectionView(self, numberOfItemsInSection: 0)
    }

    public var preloadCount: Int = 3

    private var _isRotating: Bool = false
    public func beginRotate() {
        _isRotating = true
    }

    public func endRotate() {
        _isRotating = false
    }

    public func beginChangingBarState() {
        if let layout = collectionViewLayout as? PagingViewFlowLayout {
            layout.ignoreTargetContentOffset = true
        }
    }

    public func endChangingBarState() {
        if let layout = collectionViewLayout as? PagingViewFlowLayout {
            layout.ignoreTargetContentOffset = false
        }
    }

    public var isDoubleSpread: Bool = false {
        didSet {
            currentPageIndex = currentPageIndex.convert(double: isDoubleSpread)
            if let layout = collectionViewLayout as? PagingViewFlowLayout {
                layout.isDoubleSpread = isDoubleSpread
            }
        }
    }

    func setLayoutIndex(_ index: VisibleIndex) {
        if let flowLayout = collectionViewLayout as? PagingViewFlowLayout {
            flowLayout.currentPageIndex = index
        }
    }

    public var scrollDirection: ForwardDirection

    private var _currentPageIndex: VisibleIndex = .single(index: 0)
    public var currentPageIndex: VisibleIndex {
        set {
            _currentPageIndex = newValue
            scrollTo(index: newValue.primaryIndex())
        }
        get {
            if isDoubleSpread {
                return .double(indexes: visiblePageIndexes)
            }

            return _currentPageIndex
        }
    }

    public var visiblePageIndexes: [Int] {
        return indexPathsForVisibleItems.map { (indexPath) -> Int in
            Int(indexPath.row)
        }
    }

    public var isLegacyLayoutSystem: Bool {
        if #available(iOS 11.0, *) {
            return false
        } else if scrollDirection == .left {
            return true
        } else {
            return false
        }
    }

    public init(frame: CGRect, forwardDirection: ForwardDirection) {
        scrollDirection = forwardDirection
        if forwardDirection == .left {
            super.init(frame: frame, collectionViewLayout: PagingViewRightToLeftFlowLayout())
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            } else {
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        } else if forwardDirection == .right {
            super.init(frame: frame, collectionViewLayout: PagingViewHorizontalFlowLayout())
        } else if forwardDirection == .up {
            super.init(frame: frame, collectionViewLayout: PagingViewBottomToTopLayout())
        } else { // .down
            super.init(frame: frame, collectionViewLayout: PagingViewVerticalFlowLayout())
        }

        delegate = self
        dataSource = self
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func scrollTo(index: Int, animated: Bool = false) {
        if index > numberOfPages - 1 || index < 0 {
            return
        }
        var position: UICollectionView.ScrollPosition {
            if scrollDirection.isHorizontal() {
                if isDoubleSpread {
                    if index % 2 == 0 {
                        return .left
                    }
                    return .right
                }
                return .centeredHorizontally
            } else {
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
                view.resize(pageIndex: cell.pageIndex, scrollDirection: scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
            }
        }
    }

    public func changeDirection(_ forwardDirection: ForwardDirection) {
        scrollDirection = forwardDirection
        if forwardDirection == .left {
            collectionViewLayout = PagingViewRightToLeftFlowLayout()
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = .never
            } else {
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        } else {
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            if forwardDirection == .right {
                collectionViewLayout = PagingViewHorizontalFlowLayout()
            } else if forwardDirection == .up {
                collectionViewLayout = PagingViewBottomToTopLayout()
            } else { // .down
                collectionViewLayout = PagingViewVerticalFlowLayout()
            }
        }

        reloadData()
    }

    override open func reloadData() {
        collectionViewLayout.invalidateLayout()
        super.reloadData()
    }

    override open func layoutSubviews() {
        beginChangingBarState()
        super.layoutSubviews()
        endChangingBarState()
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

extension PagingView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _isRotating {
            return
        }
        guard let pagingDelegate = pagingDelegate else {
            return
        }
        let position = scrollView.contentOffset.x / scrollView.frame.width
        if scrollDirection.isHorizontal() {
            pagingDelegate.pagingView(pagingView: self, didScrollToPosition: position)
            if isDoubleSpread {
                let newIndex: VisibleIndex = .double(indexes: visiblePageIndexes)
                if _currentPageIndex != newIndex {
                    pagingDelegate.pagingView(pagingView: self, willChangeIndexTo: newIndex, currentIndex: _currentPageIndex)
                }
                _currentPageIndex = newIndex
            } else {
                let to = Int(position + 0.5)
                let newIndex: VisibleIndex = to.single()
                if _currentPageIndex != newIndex {
                    pagingDelegate.pagingView(pagingView: self, willChangeIndexTo: newIndex, currentIndex: _currentPageIndex)
                }
                _currentPageIndex = newIndex
            }
        } else {
            pagingDelegate.pagingView(pagingView: self, didScrollToPosition: scrollView.contentOffset.y)
            if let index = indexPathsForVisibleItems.sorted().middle {
                let to = index.row
                let newIndex: VisibleIndex = to.convert(double: isDoubleSpread)
                if _currentPageIndex != newIndex {
                    pagingDelegate.pagingView(pagingView: self, willChangeIndexTo: newIndex, currentIndex: _currentPageIndex)
                }
                _currentPageIndex = newIndex
            }
        }
        setLayoutIndex(_currentPageIndex)
    }

    public func scrollViewWillBeginDragging(_: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDragging(pagingView: self)
        }
    }

    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDragging(pagingView: self, willDecelerate: decelerate)
            if decelerate == false {
                pagingDelegate.pagingView(pagingView: self, didChangeIndexTo: currentPageIndex)
            }
        }
    }

    public func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewWillBeginDecelerating(pagingView: self)
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndDecelerating(pagingView: self)
            pagingDelegate.pagingView(pagingView: self, didChangeIndexTo: currentPageIndex)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingViewDidEndScrollingAnimation(pagingView: self)
        }
    }
}

extension PagingView: UICollectionViewDelegate {}

extension PagingView: UICollectionViewDataSource {
    override open func numberOfItems(inSection section: Int) -> Int {
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
        let cell = pagingDataSource.collectionView(collectionView, cellForItemAt: indexPath)
        cell._pageIndex = indexPath.row
        if isLegacyLayoutSystem {
            cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }

        // prefetch
        let prefetchStartIndex = max(0, indexPath.row - preloadCount)
        let prefetchEndIndex = min(numberOfPages - 1, indexPath.row + preloadCount)
        for i in prefetchStartIndex ..< prefetchEndIndex {
            pagingDataSource.pagingView(pagingView: self, preloadItemAt: i)
        }

        // cancel
        let cancelStartIndex = min(max(0, indexPath.row - preloadCount - 1), numberOfPages - 1)
        let cancelEndIndex = max(min(numberOfPages - 1, indexPath.row + preloadCount + 1), 0)
        for i in cancelStartIndex ..< prefetchStartIndex {
            pagingDataSource.pagingView(pagingView: self, cancelPreloadingItemAt: i)
        }
        for i in prefetchEndIndex ..< cancelEndIndex {
            pagingDataSource.pagingView(pagingView: self, cancelPreloadingItemAt: i)
        }

        return cell
    }

    public func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pagingDelegate = pagingDelegate, let view = cell as? (UIView & PageViewProtocol) else {
            return
        }

        pagingDelegate.pagingView(pagingView: self, didEndDisplaying: view, index: indexPath.row)
    }
}

extension PagingView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let pagingDelegate = pagingDelegate else {
            return CGSize.zero
        }
        return pagingDelegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
    }
}
