//
//  RDRemoteImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class RDRemoteImageContentData: RDImageContentData {
    public var tempolaryImageView: RDImageScrollView?
    let request: URLRequest
    let session: URLSession
    var task: URLSessionTask?
    var lazyConfigurationHandler: ((UIImage?) -> Void)?
    public var configuration: URLSessionConfiguration?
    public var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    public var imageDecodeHandler: ((Data) -> UIImage?)?
    
    public init(request: URLRequest, session: URLSession) {
        self.session = session
        self.request = request
        super.init(imageName: "")
    }
    
    override public func stopPreload() {
        if let task = task {
            task.cancel()
        }
    }
    
    override public func contentView(frame: CGRect) -> UIView {
        return RDImageScrollView(frame: frame)
    }
    
    override public func preload() {
        if image == nil {
            task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let weakSelf = self, let data = data else {
                    return
                }
                if let handler = weakSelf.completionHandler {
                    handler(data, response, error)
                }
                if let decodeHandler = weakSelf.imageDecodeHandler {
                    weakSelf.image = decodeHandler(data)
                }
                else {
                    weakSelf.image = UIImage(data: data)
                }
                
                if let handler = weakSelf.lazyConfigurationHandler {
                    handler(weakSelf.image)
                }
            })
            
            task?.resume()
        }
    }
    
    override public func reload() {
        image = nil
        preload()
    }
    
    override public func configure(view: UIView) {
        super.configure(view: view)
        if image == nil {
            let imageView = view as! RDImageScrollView
            tempolaryImageView = imageView
            lazyConfigurationHandler = { [weak self] (image) in
                guard let weakSelf = self else {
                    return
                }
                if weakSelf.tempolaryImageView == imageView {
                    DispatchQueue.main.async {
                        weakSelf.tempolaryImageView?.image = image
                    }
                }
            }
        }
    }
}
