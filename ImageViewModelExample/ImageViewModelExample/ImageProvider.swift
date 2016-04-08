//
//  ImageProvider.swift
//  ImageViewModelExample
//
//  Created by Sergii Gavryliuk on 2016-04-07.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import ImageViewModel


let globalImageProvider = SimpleImageProvider(cache: ImageProviderCache())

struct SimpleImageProvider: ImageProvider {
    
    let backgroundScheduler: QueueScheduler
    let imageCache: ImageProviderCache
    
    init(cache: ImageProviderCache, backgroundQueue: QueueScheduler = QueueScheduler()) {
        self.imageCache = cache
        self.backgroundScheduler = backgroundQueue
    }
    
    func image(image: UIImage, size: CGSize) -> SignalProducer<UIImage, NoError> {
        return resizeImage(size, image: image)
    }
    
    func image(url url: NSURL, size: CGSize) -> SignalProducer<UIImage, NoError> {
        return self.cachedDownloadSignal(url).flatMap(.Merge) { image in
            return self.cachedResizedImage(image, size:size, key: "\(url)_\(size)")
        }
    }
    
    
    func cachedDownloadSignal(url: NSURL) -> SignalProducer<UIImage, NoError> {
        let downloadSignal = self.downloadImageSignal(url)
        return self.imageCache.cachedImage("\(url)") { downloadSignal }.ignoreErrors()
    }
    
    func cachedResizedImage(image: UIImage, size: CGSize, key: String) -> SignalProducer<UIImage, NoError> {
        let signal = self.resizeImage(size, image: image).promoteErrors(NSError)
        return self.imageCache.cachedImage(key) { signal }.ignoreErrors()
    }
    
    func downloadImageSignal(url: NSURL) -> SignalProducer<UIImage, NSError> {
        return SignalProducer<UIImage, NSError> {
            sink, disposables in
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
                data, response, error in
                if (error != nil) {
                    sink.sendFailed(error!)
                } else {
                    if let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale) {
                        sink.sendNext(image)
                        sink.sendCompleted()
                    } else {
                        sink.sendFailed(NSError(domain: "HTTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct image from returned data"]))
                    }
                }
            }
            disposables.addDisposable {
                task.cancel()
            }
            task.resume()
            }.observeOn(UIScheduler())
    }
    
    func resizeImage(size: CGSize, image: UIImage) -> SignalProducer<UIImage, NoError> {
        return
            SignalProducer<UIImage, NoError> { sink, _ in sink.sendNext(image.resizedImage(size)) }
                .startOn(self.backgroundScheduler)
                .observeOn(UIScheduler())
    }
}


class ImageProviderCache {
    private let cache = NSCache()
    func cachedImage(key: String, signalBlock: () -> SignalProducer<UIImage, NSError>) -> SignalProducer<UIImage, NSError> {
        if let image = cache.objectForKey(key) as? UIImage {
            return SignalProducer(value: image)
        } else {
            return signalBlock()
                .on { self.cache.setObject($0, forKey: key) }
        }
    }
}