//
//  ViewController.swift
//  RDImageViewerController
//
//  Created by Akira on 04/08/2019.
//  Copyright (c) 2019 Akira. All rights reserved.
//

import UIKit
import RDImageViewerController

class ViewController: UIViewController {
    @IBOutlet weak var showSlider: UISwitch!
    @IBOutlet weak var showHud: UISwitch!
    @IBOutlet weak var scrollvertically: UISwitch!
    @IBOutlet weak var doubleSided: UISwitch!
    
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
    }
    
    func commonSetup(viewController: RDImageViewerController) {
        viewController.isSliderEnabled = showSlider.isOn
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.isPageNumberHudEnabled = showHud.isOn
        viewController.doubleSidedConfiguration = DoubleSidedConfiguration(portrait: false, landscape: doubleSided.isOn)
        if scrollvertically.isOn {
            viewController.showSlider = false
            viewController.isSliderEnabled = false
        }
    }

    @IBAction func image(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.imageContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func remoteImage(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.remoteContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Remote Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showScrollView(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.scrollContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Scroll View"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showView(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.textLabelContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "View"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func aspectFit(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.aspectFitContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Aspect Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func displayFit(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.imageContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Display Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func viewAndImage(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: ContentsFactory.viewAndImageContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func reload(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = ReloadImageViewerController(contents: ContentsFactory.scrollContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func left(_ sender: Any) {
        let direction: RDPagingView.ForwardDirection = .left
        let viewController = RDImageViewerController(contents: ContentsFactory.imageContents(), direction: direction)
        commonSetup(viewController: viewController)
        viewController.title = "Left"
        navigationController?.pushViewController(viewController, animated: true)
    }
}

