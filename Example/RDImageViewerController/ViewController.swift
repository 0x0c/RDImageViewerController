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
    
    // https://gist.github.com/asarode/7b343fa3fab5913690ef
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func remoteContents() -> [RDRemoteImageContentData] {
        var contents = [RDRemoteImageContentData]()
        for i in 1...12 {
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(i).JPG")!)
            let data = RDRemoteImageContentData(request: request, session: URLSession.shared)
            data.landscapeMode = .displayFit
            contents.append(data)
        }
        
        return contents
    }
    
    func scrollContents() -> [ScrollContentData] {
        var contents = [ScrollContentData]()
        for _ in 1...12 {
            let data = ScrollContentData(color: generateRandomColor())
            contents.append(data)
        }
        
        return contents
    }
    
    func textLabelContents() -> [TextLabelViewContentData] {
        var contents = [TextLabelViewContentData]()
        for i in 1...12 {
            let data = TextLabelViewContentData(text: "\(i)")
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
    
    func aspectFitContents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 1...12 {
            let data = RDImageContentData(imageName: "\(i).JPG")
            data.landscapeMode = .aspectFit
            contents.append(data)
        }
        
        return contents
    }
    
    func viewAndImageContents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 1...12 {
            if i % 2 == 0 {
                let data = RDImageContentData(imageName: "\(i).JPG")
                data.landscapeMode = .displayFit
                contents.append(data)
            }
            else {
                let data = TextLabelViewContentData(text: "\(i)")
                contents.append(data)
            }
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
        viewController.title = "Image"
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
        viewController.title = "Remote Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showScrollView(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: scrollContents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.title = "Scroll View"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showView(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: textLabelContents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.title = "View"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func aspectFit(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: aspectFitContents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.title = "Aspect Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func displayFit(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: contents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.title = "Display Fit"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func viewAndImage(_ sender: Any) {
        var direction: RDPagingView.ForwardDirection = .right
        if scrollvertically.isOn {
            direction = .down
        }
        
        let viewController = RDImageViewerController(contents: viewAndImageContents(), direction: direction)
        viewController.showSlider = showSlider.isOn
        viewController.showPageNumberHud = showHud.isOn
        viewController.title = "View and Image"
        navigationController?.pushViewController(viewController, animated: true)
    }
}

