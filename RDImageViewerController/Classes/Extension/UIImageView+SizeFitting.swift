//
//  UIImageView+SizeFitting.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/11/02.
//

extension UIImageView {
    open var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    open func fitToAspect(containerSize: CGSize) {
        sizeToFit()
        let height = containerSize.height
        let width = containerSize.width
        let imageHeight = max(1, frame.height)
        let imageWidth = max(1, frame.width)
        var scale: CGFloat = 1.0

        if width < height {
            // device portrait
            if image?.isLandspace() ?? false {
                // landscape image
                // fit imageWidth to viewWidth
                scale = width / imageWidth
            }
            else {
                // portrait image
                if imageWidth / imageHeight > width / height {
                    // fit imageWidth to viewWidth
                    scale = width / imageWidth
                }
                else {
                    // fit imageHeight to viewHeight
                    scale = height / imageHeight
                }
            }
        }
        else {
            // device landscape
            if image?.isLandspace() ?? false {
                // image landscape
                if imageWidth / imageHeight > width / height {
                    // fit imageWidth to viewWidth
                    scale = width / imageWidth
                }
                else {
                    // fit imageHeight to viewHeight
                    scale = height / imageHeight
                }
            }
            else {
                // image portrait
                // fit imageHeight to viewHeight
                scale = height / imageHeight
            }
        }

        frame = CGRect(
            x: 0,
            y: 0,
            width: imageWidth * scale,
            height: imageHeight * scale
        )
    }

    open func fitToDisplay(containerSize: CGSize) {
        sizeToFit()
        let height = containerSize.height
        let width = containerSize.width
        if width < height {
            // portrait
            fitToAspect(containerSize: containerSize)
        }
        else {
            var scale: CGFloat {
                if width > height {
                    return width / max(1, frame.width)
                }
                return height / max(1, frame.height)
            }

            frame = CGRect(
                x: 0,
                y: 0,
                width: frame.width * scale,
                height: frame.height * scale
            )
            if height > frame.height {
                center = CGPoint(x: width / 2.0, y: height / 2.0)
            }
        }
    }
}
