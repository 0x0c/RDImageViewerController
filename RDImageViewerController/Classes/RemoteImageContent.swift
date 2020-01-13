//
//  RDRemoteImageContentData.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

open class RemoteImageContent: ImageContent {
    public var task: URLSessionTask?
    public let request: URLRequest
    public let session: URLSession
    public var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    public var imageDecodeHandler: ((Data) -> UIImage?)?
    public var lazyCompletionHandler: ((PageContent) -> Void)?
    
    public init(type: PageContent.PresentationType, request: URLRequest, session: URLSession) {
        self.session = session
        self.request = request
        super.init(type: type)
    }
    
    public convenience init(request: URLRequest, session: URLSession) {
        self.init(type: .class(RemoteImageScrollView.self), request: request, session: session)
    }
    
    override open func stopPreload() {
        if let t = task {
            t.cancel()
            task = nil
        }
    }
    
    @objc override open func reload(completion: ((PageContent) -> Void)?) {
        image = nil
        preload(completion: completion)
    }
    
    @objc override open func preload() {
        preload(completion: nil)
    }
    
    @objc override open func isPreloading() -> Bool {
        if task != nil {
            return true
        }
        return false
    }
    
    open override func preload(completion: ((PageContent) -> Void)?) {
        if completion != nil {
            lazyCompletionHandler = completion
        }
        
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
