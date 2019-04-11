//
//  RDRemoteImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class RDRemoteImageContentData: RDImageContentData {
    let request: URLRequest
    let session: URLSession
    var task: URLSessionTask?
    public var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    public var imageDecodeHandler: ((Data) -> UIImage?)?
    var lazyCompletionHandler: ((RDPageContentData) -> Void)?
    
    public init(request: URLRequest, session: URLSession) {
        self.session = session
        self.request = request
        super.init(type: .class(RDRemoteImageScrollView.self))
    }
    
    override open func stopPreload() {
        if let task = task {
            task.cancel()
        }
    }
    
    @objc override open func preload() {
        preload(completion: nil)
    }
    
    @objc override open func reload() {
        image = nil
        preload()
    }
    
    open override func preload(completion: ((RDPageContentData) -> Void)?) {
        lazyCompletionHandler = completion
        
        if image != nil {
            if let handler = lazyCompletionHandler {
                handler(self)
            }
        }
        else if task == nil  {
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
                if let handler = weakSelf.lazyCompletionHandler {
                    handler(weakSelf)
                }
            })
            
            task?.resume()
        }
    }
}
