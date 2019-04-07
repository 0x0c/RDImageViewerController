//
//  RDRemoteImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

class RDRemoteImageContentData: RDImageContentData {
    private var tempolaryImageView: RDImageScrollView?
    private let request: URLRequest
    private let session: URLSession
    private var task: URLSessionTask?
    private var lazyConfigurationHandler: ((UIImage?) -> Void)?
    var configuration: URLSessionConfiguration?
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    var imageDecodeHandler: ((Data) -> UIImage?)?
    
    init(request: URLRequest, session: URLSession) {
        self.session = session
        self.request = request
        super.init(imageName: "")
    }
    
    override func stopPreload() {
        if let task = task {
            task.cancel()
        }
    }
    
    override func contentView(frame: CGRect) -> UIView {
        return RDImageScrollView(frame: frame)
    }
    
    override func preload() {
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
    
    override func reload() {
        image = nil
        preload()
    }
    
    override func configure(view: UIView) {
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
