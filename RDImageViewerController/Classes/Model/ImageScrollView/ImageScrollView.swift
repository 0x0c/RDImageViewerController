//
//  RDImageScrollView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class ImageScrollView: UICollectionViewCell, PageView {
    public struct ImageAlignment {
        public enum HorizontalAlignment {
            case left
            case right
            case center
        }

        public enum VerticalAlignment {
            case top
            case bottom
            case center
        }

        public var horizontal: HorizontalAlignment = .center
        public var vertical: VerticalAlignment = .center
    }

    public enum LandscapeMode {
        case aspectFit
        case displayFit
    }

    open var scrollView: UIScrollView
    public let zoomRect = CGSize(width: 100, height: 100)

    open var alignment: ImageAlignment = ImageAlignment(horizontal: .center, vertical: .center) {
        didSet {
            fixImageViewPosition()
        }
    }

    open var mode: LandscapeMode = .aspectFit {
        didSet {
            adjustContentAspect()
        }
    }

    open var borderColor: UIColor? {
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

    open var borderWidth: CGFloat {
        set {
            imageView.layer.borderWidth = newValue
        }
        get {
            imageView.layer.borderWidth
        }
    }

    open var image: UIImage? {
        set {
            imageView.image = newValue
            if imageView.image == nil {
                indicatorView.startAnimating()
            }
            else {
                indicatorView.stopAnimating()
            }
            adjustContentAspect()
            fixImageViewPosition()
        }
        get {
            imageView.image
        }
    }

    public var imageView = UIImageView()
    var indicatorView = UIActivityIndicatorView(style: .white)
    var zoomGesture = UITapGestureRecognizer(target: nil, action: nil)

    override public init(frame: CGRect) {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        super.init(frame: frame)

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)

        imageView.center = scrollView.center
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        indicatorView.center = imageView.center
        indicatorView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        indicatorView.startAnimating()
        addSubview(indicatorView)

        zoomGesture = UITapGestureRecognizer(target: self, action: #selector(zoomImage(gesture:)))
        zoomGesture.numberOfTapsRequired = 2
        zoomGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(zoomGesture)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func zoomImage(gesture: UIGestureRecognizer) {
        let imageView = gesture.view as! ImageScrollView
        if imageView.scrollView.zoomScale > imageView.scrollView.minimumZoomScale {
            imageView.scrollView.setZoomScale(1.0, animated: true)
        }
        else if imageView.scrollView.zoomScale < imageView.scrollView.maximumZoomScale {
            let position = gesture.location(in: imageView.scrollView)
            imageView.scrollView.zoom(
                to: .init(
                    x: position.x - zoomRect.width / 2,
                    y: position.y - zoomRect.height / 2,
                    width: zoomRect.width,
                    height: zoomRect.height
                ),
                animated: true
            )
        }
    }

    private func fixImageViewPosition() {
        switch alignment.horizontal {
        case .left:
            imageView.frame.origin.x = 0
        case .right:
            imageView.frame.origin.x = frame.width - imageView.frame.width
        case .center:
            imageView.center.x = scrollView.center.x
        }

        switch alignment.vertical {
        case .top:
            imageView.frame.origin.y = 0
        case .bottom:
            imageView.frame.origin.y = frame.height - imageView.frame.height
        case .center:
            imageView.center.y = scrollView.center.y
        }
    }

    open func adjustContentAspect() {
        switch mode {
        case .aspectFit:
            imageView.fitToAspect(containerSize: frame.size)
            scrollView.contentSize = imageView.frame.size
            scrollView.setZoomScale(1.0, animated: false)
        case .displayFit:
            imageView.fitToDisplay(containerSize: frame.size)
            let height = frame.height
            let width = frame.width
            if width > height {
                scrollView.setZoomScale(1.0, animated: false)
            }
        }
        fixImageViewPosition()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

    public func addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: UIGestureRecognizer) {
        gesture.require(toFail: zoomGesture)
        addGestureRecognizer(gesture)
    }

    // MARK: RDPageContentDataView

    open func resize() {
        adjustContentAspect()
    }

    public func resize(
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) {
        if pageIndex % 2 == 0 {
            var horizontalAlignment: ImageAlignment.HorizontalAlignment {
                if isDoubleSpread == false {
                    return .center
                }
                if scrollDirection == .right {
                    return .right
                }
                return .left
            }
            alignment = ImageAlignment(horizontal: horizontalAlignment, vertical: .center)
        }
        else {
            var horizontalAlignment: ImageAlignment.HorizontalAlignment {
                if isDoubleSpread == false {
                    return .center
                }
                if scrollDirection == .right {
                    return .left
                }
                return .right
            }
            alignment = ImageAlignment(horizontal: horizontalAlignment, vertical: .center)
        }
        resize()
    }

    open func configure(
        data: PageContent,
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) {
        guard let data = data as? ImageContent else {
            return
        }
        scrollView.maximumZoomScale = data.maximumZoomScale
        mode = data.landscapeMode
        scrollView.setZoomScale(1.0, animated: false)
        if RDImageViewerController.rd_isLandscape(), isDoubleSpread {
            resize(pageIndex: pageIndex, scrollDirection: scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
        }
        image = data.image
    }
}

extension ImageScrollView: UIScrollViewDelegate {
    public func viewForZooming(in _: UIScrollView) -> UIView? {
        imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let subView = scrollView.subviews.first {
            var x = subView.center.x
            var y = subView.center.y

            if alignment.horizontal == .center {
                var offsetX: CGFloat {
                    if scrollView.bounds.width > scrollView.contentSize.width {
                        return (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
                    }
                    return 0
                }
                x = scrollView.contentSize.width * 0.5 + offsetX
            }
            if alignment.vertical == .center {
                var offsetY: CGFloat {
                    if scrollView.bounds.height > scrollView.contentSize.height {
                        return (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
                    }
                    return 0
                }
                y = scrollView.contentSize.height * 0.5 + offsetY
            }
            subView.center = CGPoint(x: x, y: y)
        }
    }
}

extension UIImage {
    func isLandspace() -> Bool {
        size.width > size.height
    }
}
