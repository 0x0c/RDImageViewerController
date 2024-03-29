//
//  DoubleImageView.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/11/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

open class DoubleImageView: UICollectionViewCell, PageViewRepresentation {
    private let zoomRect = CGSize(width: 100, height: 100)
    private var scrollView: UIScrollView
    private var zoomGesture = UITapGestureRecognizer(target: nil, action: nil)
    private var rightImageView = UIImageView()
    private var leftImageView = UIImageView()
    private var stackView = UIStackView()

    override init(frame: CGRect) {
        scrollView = UIScrollView(
            frame: .init(
                x: 0,
                y: 0,
                width: frame.width,
                height: frame.height
            )
        )

        rightImageView = UIImageView(
            frame: .init(
                x: frame.width / 2.0,
                y: 0,
                width: frame.width / 2.0,
                height: frame.height
            )
        )
        rightImageView.contentMode = .scaleAspectFit

        leftImageView = UIImageView(
            frame: .init(
                x: 0,
                y: 0,
                width: frame.width / 2.0,
                height: frame.height
            )
        )
        leftImageView.contentMode = .scaleAspectFit

        stackView.frame = .init(
            x: 0,
            y: 0,
            width: frame.width,
            height: frame.height
        )
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(leftImageView)
        stackView.addArrangedSubview(rightImageView)

        super.init(frame: frame)

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)

        scrollView.addSubview(stackView)

        zoomGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(zoomImage(gesture:))
        )
        zoomGesture.numberOfTapsRequired = 2
        zoomGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(zoomGesture)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func zoomImage(gesture: UIGestureRecognizer) {
        let imageView = gesture.view as! DoubleImageView
        if imageView.scrollView.zoomScale > imageView.scrollView.minimumZoomScale {
            imageView.scrollView.setZoomScale(1.0, animated: true)
        }
        else if imageView.scrollView.zoomScale < imageView.scrollView.maximumZoomScale {
            let position = gesture.location(in: imageView.scrollView)
            imageView.scrollView.zoom(
                to: CGRect(
                    x: position.x - zoomRect.width / 2,
                    y: position.y - zoomRect.height / 2,
                    width: zoomRect.width,
                    height: zoomRect.height
                ),
                animated: true
            )
        }
    }

    public func configure(
        data: PagingViewLoadable,
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) {
        guard let data = data as? DoubleImageContent else {
            return
        }
        scrollView.maximumZoomScale = data.maximumZoomScale
        scrollView.setZoomScale(1.0, animated: false)
        if RDImageViewerController.rd_isLandscape(), isDoubleSpread {
            resize(
                pageIndex: pageIndex,
                scrollDirection: scrollDirection,
                traitCollection: traitCollection,
                isDoubleSpread: isDoubleSpread
            )
        }
        rightImageView.image = data.right?.image
        leftImageView.image = data.left?.image
        rightImageView.rd_fitToAspect(
            containerSize: .init(
                width: frame.width / 2.0,
                height: frame.height
            )
        )
        leftImageView.rd_fitToAspect(
            containerSize: .init(
                width: frame.width / 2.0,
                height: frame.height
            )
        )
        stackView.frame = .init(
            x: 0,
            y: 0,
            width: min(
                ceil(leftImageView.rd_contentClippingRect.width + rightImageView.rd_contentClippingRect.width),
                frame.width
            ),
            height: max(
                leftImageView.rd_contentClippingRect.height,
                rightImageView.rd_contentClippingRect.height
            )
        )
        scrollView.contentSize = stackView.bounds.size
        stackView.center = scrollView.center
        scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
    }

    public func resize(
        pageIndex: Int,
        scrollDirection: PagingView.ForwardDirection,
        traitCollection: UITraitCollection,
        isDoubleSpread: Bool
    ) {}

    public func resize() {}
}

extension DoubleImageView: UIScrollViewDelegate {
    public func viewForZooming(in _: UIScrollView) -> UIView? {
        stackView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let subView = scrollView.subviews.first {
            var offsetX: CGFloat {
                if scrollView.bounds.width > scrollView.contentSize.width {
                    return (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
                }
                return 0
            }
            let x = scrollView.contentSize.width * 0.5 + offsetX
            var offsetY: CGFloat {
                if scrollView.bounds.height > scrollView.contentSize.height {
                    return (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
                }
                return 0
            }
            let y = scrollView.contentSize.height * 0.5 + offsetY
            subView.center = CGPoint(x: x, y: y)
        }
    }
}
