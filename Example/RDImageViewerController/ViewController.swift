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
    
    func remoteContents() -> [RDRemoteImageContentData] {
        var contents = [RDRemoteImageContentData]()
        for i in 0..<12 {
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(i).JPG")!)
            let data = RDRemoteImageContentData(request: request, session: URLSession.shared)
            data.landscapeMode = .displayFit
            contents.append(data)
        }
        
        return contents
    }
    
    func contents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 1...12 {
            let data = RDImageContentData(imageName: "\(i).JPG")
            data.landscapeMode = .displayFit
            contents.append(data)
        }
        
        return contents
    }

    @IBAction func image(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: contents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func remoteImage(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: remoteContents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showScrollView(_ sender: Any) {
        
    }
    
    @IBAction func showView(_ sender: Any) {
        
    }
    
    @IBAction func aspectFit(_ sender: Any) {
        
    }
    
    @IBAction func displayFit(_ sender: Any) {
        
    }
    
    @IBAction func viewAndImage(_ sender: Any) {
        
    }
}

