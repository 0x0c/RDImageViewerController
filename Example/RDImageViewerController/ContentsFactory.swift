//
//  ContentsFactory.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RDImageViewerController

class ContentsFactory {
    // https://gist.github.com/asarode/7b343fa3fab5913690ef
    static func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    static func remoteContents() -> [RDRemoteImageContentData] {
        var contents = [RDRemoteImageContentData]()
        for i in 1...12 {
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(i).JPG")!)
            let data = RDRemoteImageContentData(request: request, session: URLSession.shared)
            data.landscapeMode = .displayFit
            contents.append(data)
        }
        
        return contents
    }
    
    static func scrollContents() -> [ScrollContentData] {
        var contents = [ScrollContentData]()
        for _ in 1...12 {
            let data = ScrollContentData(color: generateRandomColor())
            contents.append(data)
        }
        
        return contents
    }
    
    static func textLabelContents() -> [TextLabelViewContentData] {
        var contents = [TextLabelViewContentData]()
        for i in 1...12 {
            let data = TextLabelViewContentData(text: "\(i)")
            contents.append(data)
        }
        
        return contents
    }
    
    static func imageContents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 1...12 {
            let data = RDImageContentData(imageName: "\(i).JPG")
            data.landscapeMode = .displayFit
            contents.append(data)
        }

        return contents
    }
    
    static func aspectFitContents() -> [RDPageContentData] {
        var contents = [RDPageContentData]()
        for i in 1...12 {
            let data = RDImageContentData(imageName: "\(i).JPG")
            data.landscapeMode = .aspectFit
            contents.append(data)
        }
        
        return contents
    }
    
    static func viewAndImageContents() -> [RDPageContentData] {
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
    
    static func randomContents() -> [RDPageContentData] {
        let numberOfPages = Int(arc4random() % 20 + 1)
        var contents = [RDPageContentData]()
        for i in 0..<numberOfPages {
            contents.append(ContentsFactory.randomContent(seed: i))
        }
        
        return contents
    }
    
    static func randomContent(seed: Int) -> RDPageContentData {
        let rand = arc4random() % 4
        switch rand {
        case 0:
            return RDImageContentData(imageName: "\(seed % 12 + 1).JPG")
        case 1:
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(seed % 12 + 1).JPG")!)
            return RDRemoteImageContentData(request: request, session: URLSession.shared)
        case 2:
            return TextLabelViewContentData(text: "\(seed)")
        case 3:
            return ScrollContentData(color: generateRandomColor())
        default:
            return TextLabelViewContentData(text: "\(seed)")
        }
    }
}
