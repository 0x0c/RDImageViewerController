//
//  RDImageScrollView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class RDImageScrollView: UIScrollView {
    
    let zoomRect = CGSize(width: 100, height: 100)
    
    public enum ResizeMode {
        case aspectFit
        case displayFit
    }
    
    var _mode: ResizeMode = .aspectFit
    public var mode: ResizeMode {
        set {
            _mode = newValue
            adjustContentAspect()
        }
        get {
            return _mode
        }
    }
    public var borderColor: UIColor? {
        set {
            if let color = newValue {
                imageView.layer.borderColor = color.cgColor
            }
        }
        get {
            if let color = imageView.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
    }
    
    public var borderWidth: CGFloat {
        set {
            imageView.layer.borderWidth = newValue
        }
        get {
            return imageView.layer.borderWidth
        }
    }
    
    var imageView = UIImageView()
    var indicatorView = UIActivityIndicatorView(style: .white)
    var zoomGesture = UITapGestureRecognizer(target: nil, action: nil)

    public var image: UIImage? {
        set {
            imageView.image = newValue
            if imageView.image == nil {
                indicatorView.startAnimating()
            }
            else {
                indicatorView.stopAnimating()
            }
            adjustContentAspect()
        }
        get {
            return imageView.image
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.imageView.center = CGPoint(x: frame.midX, y: frame.midY)
        self.imageView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.imageView.layer.borderColor = UIColor.black.cgColor
        self.imageView.layer.borderWidth = 0.5
        self.addSubview(self.imageView)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.indicatorView.center = self.imageView.center
        self.indicatorView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.indicatorView.startAnimating()
        self.addSubview(self.indicatorView)
        
        self.zoomGesture = UITapGestureRecognizer(target: self, action: #selector(zoomImage(gesture:)))
        self.zoomGesture.numberOfTapsRequired = 2
        self.zoomGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.zoomGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func zoomImage(gesture: UIGestureRecognizer) {
        let scrollView = gesture.view as! UIScrollView
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(1.0, animated: true)
        }
        else {
            let position = gesture.location(in: scrollView)
            scrollView.zoom(to: CGRect(x: position.x - zoomRect.width / 2, y: position.y - zoomRect.height / 2, width: zoomRect.width, height: zoomRect.height), animated: true)
        }
    }
    
    public func adjustContentAspect() {
        switch mode {
        case .aspectFit:
            fitToAspect()
        case .displayFit:
            fitToDisplay()
        }
        setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    public func fitToAspect() {
        imageView.sizeToFit()
        let height = frame.height
        let width = frame.width
        var scale: CGFloat = 1.0
        var fitWidth = false
        if width < height {
            fitWidth = true
            scale = width / max(1, imageView.frame.width)
        }
        else {
            scale = height / max(1, imageView.frame.height)
        }
        
        let imageEdgeLength: CGFloat = fitWidth ? imageView.frame.height : imageView.frame.width
        let viewEdgeLength: CGFloat = fitWidth ? height : width
        
        if imageEdgeLength > viewEdgeLength {
            scale = viewEdgeLength / max(1, imageEdgeLength)
        }
        
        imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width * scale, height: imageView.frame.height * scale)
        imageView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        contentSize = imageView.frame.size
        setZoomScale(1.0, animated: false)
    }
    
    public func fitToDisplay() {
        imageView.sizeToFit()
        let height = frame.height
        let width = frame.width
        if height > width {
            fitToAspect()
        }
        else {
            let scale = width > height ? width / max(1, imageView.frame.width) : height / max(1, imageView.frame.height)
            imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width * scale, height: imageView.frame.height * scale)
            contentSize = imageView.frame.size
            setZoomScale(1.0, animated: false)
            
        }
    }
    
    public func addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: UIGestureRecognizer) {
        gesture.require(toFail: zoomGesture)
    }

}

extension RDImageScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let subView = scrollView.subviews.first {
            let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0
            let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0
            subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        }
    }
}
