//
//  RDImageScrollView.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class ImageScrollView: UICollectionViewCell, PageViewProtocol {
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
            return imageView.layer.borderWidth
        }
    }

    open var image: UIImage? {
        set {
            imageView.image = newValue
            if imageView.image == nil {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
            adjustContentAspect()
            fixImageViewPosition()
        }
        get {
            return imageView.image
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
        } else if imageView.scrollView.zoomScale < imageView.scrollView.maximumZoomScale {
            let position = gesture.location(in: imageView.scrollView)
            imageView.scrollView.zoom(to: CGRect(x: position.x - zoomRect.width / 2, y: position.y - zoomRect.height / 2, width: zoomRect.width, height: zoomRect.height), animated: true)
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
            fitToAspect()
        case .displayFit:
            fitToDisplay()
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

    open func fitToAspect() {
        imageView.sizeToFit()
        let viewHeight = frame.height
        let viewWidth = frame.width
        let imageHeight = max(1, imageView.frame.height)
        let imageWidth = max(1, imageView.frame.width)
        var scale: CGFloat = 1.0

        if viewWidth < viewHeight {
            // device portrait
            if image?.isLandspace() ?? false {
                // landscape image
                // fit imageWidth to viewWidth
                scale = viewWidth / imageWidth
            } else {
                // portrait image
                if imageWidth / imageHeight > viewWidth / viewHeight {
                    // fit imageWidth to viewWidth
                    scale = viewWidth / imageWidth
                } else {
                    // fit imageHeight to viewHeight
                    scale = viewHeight / imageHeight
                }
            }
        } else {
            // device landscape
            if image?.isLandspace() ?? false {
                // image landscape
                if imageWidth / imageHeight > viewWidth / viewHeight {
                    // fit imageWidth to viewWidth
                    scale = viewWidth / imageWidth
                } else {
                    // fit imageHeight to viewHeight
                    scale = viewHeight / imageHeight
                }
            } else {
                // image portrait
                // fit imageHeight to viewHeight
                scale = viewHeight / imageHeight
            }
        }

        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth * scale, height: imageHeight * scale)
        fixImageViewPosition()
        scrollView.contentSize = imageView.frame.size
        scrollView.setZoomScale(1.0, animated: false)
    }

    open func fitToDisplay() {
        imageView.sizeToFit()
        let height = frame.height
        let width = frame.width
        if width < height {
            // portrait
            fitToAspect()
        } else {
            let scale = width > height ? width / max(1, imageView.frame.width) : height / max(1, imageView.frame.height)
            imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width * scale, height: imageView.frame.height * scale)
            if height > imageView.frame.height {
                imageView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
            }
            scrollView.setZoomScale(1.0, animated: false)
        }
    }

    public func addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: UIGestureRecognizer) {
        gesture.require(toFail: zoomGesture)
        addGestureRecognizer(gesture)
    }

    // MARK: RDPageContentDataView

    open func resize() {
        adjustContentAspect()
    }

    public func resize(pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection _: UITraitCollection, isDoubleSpread _: Bool) {
        if pageIndex % 2 == 0 {
            var horizontalAlignment: ImageAlignment.HorizontalAlignment {
                if scrollDirection == .right {
                    return .right
                }
                return .left
            }
            alignment = ImageAlignment(horizontal: horizontalAlignment, vertical: .center)
        } else {
            var horizontalAlignment: ImageAlignment.HorizontalAlignment {
                if scrollDirection == .right {
                    return .left
                }
                return .right
            }
            alignment = ImageAlignment(horizontal: horizontalAlignment, vertical: .center)
        }
        resize()
    }

    open func configure(data: PageContentProtocol, pageIndex: Int, scrollDirection: PagingView.ForwardDirection, traitCollection: UITraitCollection, isDoubleSpread: Bool) {
        guard let data = data as? ImageContent else {
            return
        }
        scrollView.maximumZoomScale = data.maximumZoomScale
        mode = data.landscapeMode
        scrollView.setZoomScale(1.0, animated: false)
        if traitCollection.isLandscape(), isDoubleSpread {
            resize(pageIndex: pageIndex, scrollDirection: scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
        }
        image = data.image
    }
}

extension ImageScrollView: UIScrollViewDelegate {
    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let subView = scrollView.subviews.first {
            var x = subView.center.x
            var y = subView.center.y

            if alignment.horizontal == .center {
                let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0
                x = scrollView.contentSize.width * 0.5 + offsetX
            }
            if alignment.vertical == .center {
                let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0
                y = scrollView.contentSize.height * 0.5 + offsetY
            }
            subView.center = CGPoint(x: x, y: y)
        }
    }
}

extension UIImage {
    func isLandspace() -> Bool {
        return size.width > size.height
    }
}
