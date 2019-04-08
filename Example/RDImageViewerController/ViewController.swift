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
    
    func contents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 0..<12 {
            let data = RDImageContentData(imageName: "\(i + 1).JPG")
            contents.append(data)
        }
        
        return contents
    }

    @IBAction func image(_ sender: Any) {
        let viewController = RDImageViewerController(contents: contents(), direction: .left)
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

