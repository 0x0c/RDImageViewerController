//
//  RDPagingView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

@objc public protocol RDPagingViewDataSource {
    func pagingView(pagingView: RDPagingView, viewForIndex index: Int) -> UIView
    func pagingView(pagingView: RDPagingView, reuseIdentifierForIndex index: Int) -> String
}

@objc public protocol RDPagingViewDelegate {
    @objc optional func pagingView(pagingView: RDPagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView])
    @objc optional func pagingView(pagingView: RDPagingView, willViewDequeue view: UIView)
    @objc optional func pagingView(pagingView: RDPagingView, willViewEnqueue view: UIView)
    @objc optional func pagingView(pagingView: RDPagingView, willChangeIndexTo index: Int)
    @objc optional func pagingView(pagingView: RDPagingView, didScrollToPosition position: CGFloat)
    @objc optional func pagingViewWillBeginDragging(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndDragging(pagingView: RDPagingView, willDecelerate decelerate: Bool)
    @objc optional func pagingViewWillBeginDecelerating(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndDecelerating(pagingView: RDPagingView)
    @objc optional func pagingViewDidEndScrollingAnimation(pagingView: RDPagingView)
}

open class RDPagingView: UIScrollView {
    
    public enum ForwardDirection {
        case right
        case left
        case up
        case down
        
        func isVertical() -> Bool {
            return self == .right || self == .left
        }
    }
    
    public enum MovingDirection {
        case forward
        case backward
        case unknown
    }
    
    var queueDictionary = [String : Set<UIView>]()
    var usingViews = Set<UIView>()
    var scrollViewDelegate: UIScrollViewDelegate?
    
    public var pagingDataSource: RDPagingViewDataSource?
    public var pagingDelegate: RDPagingViewDelegate?
    public let direction: ForwardDirection
    public let numberOfPages: Int
    
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
    
    public var preloadCount: Int = 0
    
    public init(frame: CGRect, numberOfPages: Int, forwardDirection: ForwardDirection) {
        self.numberOfPages = numberOfPages
        self.direction = forwardDirection
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startRotation() {
        scrollViewDelegate = delegate
        delegate = nil
    }
    
    public func endRotation() {
        delegate = scrollViewDelegate
        scrollViewDelegate = nil
    }

    public func trueIndexInScrollView(index: Int) -> Int {
        var trueIndex = index
        if direction == .left || direction == .up {
            trueIndex = numberOfPages - index - 1
        }
        
        return trueIndex
    }
    
    public func scroll(at: Int) {
        currentPageIndex = at
        let trueIndex = trueIndexInScrollView(index: at)
        if direction.isVertical() {
            setContentOffset(CGPoint(x: CGFloat(trueIndex) * frame.width, y: 0), animated: false)
        }
        else {
            setContentOffset(CGPoint(x: 0, y: CGFloat(trueIndex) * frame.height), animated: false)
        }
    }
    
    public func dequeueView(with reuseIdentifier: String) -> UIView? {
        guard let set = queueDictionary[reuseIdentifier] else {
            queueDictionary[reuseIdentifier] = Set<UIView>()
            return nil
        }
        
        return set.first
    }
    
    public func resize(with frame: CGRect, duration: TimeInterval) {
        let newSize = frame.size
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, willChangeViewSize: newSize, duration: duration, visibleViews: Array(usingViews))
        }
        
        let currentIndex = trueIndexInScrollView(index: currentPageIndex)
        if direction.isVertical() {
            contentSize = CGSize(width: CGFloat(numberOfPages) * newSize.width, height: newSize.height)
        }
        else {
            contentSize = CGSize(width: newSize.width, height: CGFloat(numberOfPages) * newSize.height)
        }

        startRotation()
        if direction.isVertical() {
            setContentOffset(CGPoint(x: CGFloat(currentIndex) * newSize.width, y: 0), animated: false)
        }
        else {
            setContentOffset(CGPoint(x: 0, y: CGFloat(currentIndex) * newSize.height), animated: false)
        }
        endRotation()
    }
    
    public func view(for index:Int) -> UIView? {
        for view in usingViews {
            if view.pageIndex == index {
                return view
            }
        }
        
        return nil
    }

    public func pageIndexWillChange(to: Int) {
        guard let pagingDataSource = pagingDataSource else {
            return
        }
        let movingDirection: MovingDirection = to - currentPageIndex > 0 ? .forward : (to - currentPageIndex < 0 ? .backward : .unknown)
        let maximumIndex = to + preloadCount
        let minimumIndex = to - preloadCount
        
        for view in usingViews {
            if view.pageIndex < minimumIndex || view.pageIndex > maximumIndex {
                viewAsPrepared(view: view, reuseIdentifier: pagingDataSource.pagingView(pagingView: self, reuseIdentifierForIndex: to))
            }
        }
        
        if movingDirection != .unknown {
            preload(numberOfViews: preloadCount, fromIndex: to)
        }
        
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, willChangeIndexTo: to)
        }
    }
    
    public func preload(numberOfViews: Int, fromIndex: Int) {
        let startIndex = max(0, fromIndex - numberOfViews)
        let endIndex = min(numberOfPages, fromIndex + numberOfViews + 1)
        for i in endIndex..<startIndex {
            if view(for: i) == nil {
                loadView(at: i)
            }
        }
    }
    
    public func loadView(at index: Int) {
        if let pagingDataSource = pagingDataSource {
            let view = pagingDataSource.pagingView(pagingView: self, viewForIndex: index)
            let trueIndex = trueIndexInScrollView(index: index)
            if direction.isVertical() {
                view.frame = CGRect(x: CGFloat(trueIndex) * frame.width, y: 0, width: frame.width, height: frame.height)
            }
            else {
                view.frame = CGRect(x: 0, y: CGFloat(trueIndex) * frame.height, width: frame.width, height: frame.height)
            }
            
            view.pageIndex = index
            viewAsUsing(view: view, reuseIdentifier: pagingDataSource.pagingView(pagingView: self, reuseIdentifierForIndex: index))
            self.addSubview(view)
        }
    }
    
    public func viewAsPrepared(view: UIView, reuseIdentifier: String) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, willViewEnqueue: view)
        }
        view.removeFromSuperview()
        usingViews.remove(view)
        if var set = queueDictionary[reuseIdentifier] {
            set.insert(view)
            queueDictionary[reuseIdentifier] = set
        }
    }
    
    public func viewAsUsing(view: UIView, reuseIdentifier: String) {
        if let pagingDelegate = pagingDelegate {
            pagingDelegate.pagingView?(pagingView: self, willViewDequeue: view)
        }
        
        if var set = queueDictionary[reuseIdentifier] {
            set.remove(view)
            queueDictionary[reuseIdentifier] = set
        }
        usingViews.insert(view)
    }
    
}

extension RDPagingView: UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var position: CGFloat = 0
        if direction.isVertical() {
            position = scrollView.contentOffset.x / scrollView.frame.width
        }
        else {
            position = scrollView.contentOffset.y / scrollView.frame.height
        }
        
        currentPageIndex = trueIndexInScrollView(index: Int(position + 0.5))
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

extension UIView
{
    static var PageIndexKey: UInt8 = 0
    public var pageIndex: Int {
        get {
            guard let associatedObject = objc_getAssociatedObject(self, &UIView.PageIndexKey) as? NSNumber else {
                let associatedObject = NSNumber(value: Int(0))
                objc_setAssociatedObject(self, &UIView.PageIndexKey, associatedObject, .OBJC_ASSOCIATION_RETAIN)
                return Int(associatedObject.intValue)
            }
            return Int(associatedObject.intValue)
        }
        
        set {
            objc_setAssociatedObject(self, &UIView.PageIndexKey, NSNumber(value: Int(newValue)), .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
