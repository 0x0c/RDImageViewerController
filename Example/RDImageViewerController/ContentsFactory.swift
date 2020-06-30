//
//  ContentsFactory.swift
//  RDImageViewerController_Example
//
//  Created by Akira Matsuda on 2019/04/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RDImageViewerController
import UIKit

class ContentsFactory {
    // https://gist.github.com/asarode/7b343fa3fab5913690ef
    static func generateRandomColor() -> UIColor {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    static func remoteContents() -> [RemoteImageContent] {
        var contents = [RemoteImageContent]()
        for i in 1 ... 12 {
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(i).JPG")!)
            let data = RemoteImageContent(request: request, session: URLSession.shared)
            data.landscapeMode = .displayFit
            contents.append(data)
        }

        return contents
    }

    static func scrollContents() -> [ScrollableContent] {
        var contents = [ScrollableContent]()
        for _ in 1 ... 12 {
            let data = ScrollableContent(color: generateRandomColor())
            contents.append(data)
        }

        return contents
    }

    static func textLabelContents() -> [TextContent] {
        var contents = [TextContent]()
        for i in 1 ... 11 {
            let data = TextContent(text: "\(i)")
            contents.append(data)
        }

        return contents
    }

    static func imageContents() -> [Content] {
        var contents = [Content]()
        for i in 1 ... 12 {
            let data = ImageContent(imageName: "\(i).JPG")
            data.landscapeMode = .displayFit
            contents.append(data)
        }

        return contents
    }

    static func aspectFitContents() -> [Content] {
        var contents = [Content]()
        for i in 1 ... 12 {
            let data = ImageContent(imageName: "\(i).JPG")
            data.landscapeMode = .aspectFit
            contents.append(data)
        }

        return contents
    }

    static func viewAndImageContents() -> [Content] {
        var contents = [Content]()
        for i in 1 ... 12 {
            if i % 2 == 0 {
                let data = ImageContent(imageName: "\(i).JPG")
                data.landscapeMode = .displayFit
                contents.append(data)
            }
            else {
                let data = TextContent(text: "\(i)")
                contents.append(data)
            }
        }

        return contents
    }

    static func multipleSizeViewContents() -> [Content] {
        var contents = [Content]()
        for i in 1 ... 11 {
            let data = TextContent(text: "\(i)")
            contents.append(data)
        }

        let data = TextContent(text: "fullscreen")
        data.forceFullscreenSize = true
        contents.append(data)

        return contents
    }

    static func randomContents() -> [Content] {
        let numberOfPages = Int(arc4random() % 20 + 1)
        var contents = [Content]()
        for i in 0 ..< numberOfPages {
            contents.append(ContentsFactory.randomContent(seed: i))
        }

        return contents
    }

    static func randomContent(seed: Int) -> Content {
        let rand = arc4random() % 4
        switch rand {
        case 0:
            return ImageContent(imageName: "\(seed % 12 + 1).JPG")
        case 1:
            let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/\(seed % 12 + 1).JPG")!)
            return RemoteImageContent(request: request, session: URLSession.shared)
        case 2:
            return TextContent(text: "\(seed)")
        case 3:
            return ScrollableContent(color: generateRandomColor())
        default:
            return TextContent(text: "\(seed)")
        }
    }
}
