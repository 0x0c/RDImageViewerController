//
//  ViewController.swift
//  RDImageViewerController
//
//  Created by Akira on 04/08/2019.
//  Copyright (c) 2019 Akira. All rights reserved.
//

import RDImageViewerController
import UIKit

class ViewController: UIViewController {
    @IBOutlet var showSlider: UISwitch!
    @IBOutlet var showHud: UISwitch!
    @IBOutlet var scrollvertically: UISwitch!
    @IBOutlet var doubleSpread: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        URLCache.shared.removeAllCachedResponses()
    }

    func commonSetup(viewController: RDImageViewerController) {
        viewController.isSliderEnabled = showSlider.isOn
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.isPageNumberHudEnabled = showHud.isOn
        viewController.configuration = DoubleSpreadConfiguration(portrait: false, landscape: doubleSpread.isOn)
        if scrollvertically.isOn {
            viewController.showSlider = false
            viewController.isSliderEnabled = false
        }
    }

    var direction: PagingView.ForwardDirection {
        if scrollvertically.isOn {
            return .down
        }
        return .right
    }

    @IBAction func image(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.imageContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "Image"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func remoteImage(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.remoteContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "Remote Image"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func showScrollView(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.scrollContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "Scroll View"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func showView(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.textLabelContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "View"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func aspectFit(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.aspectFitContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "Aspect Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func displayFit(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.imageContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "Display Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func viewAndImage(_ sender: Any) {
        var direction: PagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }

        let viewController = RDImageViewerController(
            contents: ContentsFactory.viewAndImageContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func reload(_ sender: Any) {
        let viewController = ReloadImageViewerController(
            contents: ContentsFactory.scrollContents(),
            direction: direction
        )
        commonSetup(viewController: viewController)
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func left(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.imageContents(),
            direction: .left
        )
        commonSetup(viewController: viewController)
        viewController.title = "Left"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func multipleSize(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.multipleSizeViewContents(),
            direction: .right
        )
        commonSetup(viewController: viewController)
        viewController.title = "Multiple size"
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func multipleConfiguration(_ sender: Any) {
        let viewController = RDImageViewerController(
            contents: ContentsFactory.imageContents(),
            direction: .right
        )
        commonSetup(viewController: viewController)
        viewController.configuration = SingleViewDoubleSpreadConfiguration(
            portrait: false,
            landscape: true
        )
        viewController.title = "Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
}
