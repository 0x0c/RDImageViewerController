//
//  PageHud.swift
//  Pods-RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2020/01/13.
//

import UIKit

open class PageHud: UIView {
    public let label: UILabel

    override public init(frame: CGRect) {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        super.init(frame: frame)
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        configureViews()
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureViews() {
        clipsToBounds = true

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        blurView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        blurView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        blurView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: RDImageViewerController.pageHudLabelFontSize)

        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
