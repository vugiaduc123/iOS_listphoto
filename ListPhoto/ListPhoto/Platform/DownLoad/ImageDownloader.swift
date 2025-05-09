//
//  ImageLoading.swift
//  ListPhoto
//
//  Created by Đức Vũ on 7/5/25.
//

import Foundation
import UIKit
import Network

class ImageDownloader {
    private let session: URLSession
    private let cache: NSCache<NSString, UIImage>
    private var activeTasks: [String: URLSessionDataTask]
    private let operationQueue: OperationQueue
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 3
        let urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024, diskPath: "imageCache")
        configuration.urlCache = urlCache
        self.session = URLSession(configuration: configuration)
        
        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = 300
        self.cache.totalCostLimit = 200 * 1024 * 1024 // 200 MB
        
        self.activeTasks = [:]
        
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 4
    }
}

extension ImageDownloader {
    func download(
        url: String,
        completionTask: @escaping(URLSessionDataTask) -> Void,
        placeholder: @escaping (Bool) -> Void,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        guard let normalizedUrl = URL(string: url)?.absoluteString else {
            let error = ErrorAPI.invalidURL
            completion(.failure(error))
            return
        }
        
        if let cachedImage = self.cache.object(forKey: normalizedUrl as NSString) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
                placeholder(false)
                print("Cache hit: \(cachedImage)")
                print("Cache hit: \(normalizedUrl)")
            }
            return
        }
        
        guard let link = URL(string: normalizedUrl) else {
            let error = ErrorAPI.invalidURL
            completion(.failure(error))
            return
        }
        
        if let existingTask = activeTasks[url], existingTask.state == .running {
            return
        }
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                let error = ErrorAPI.noInternet
                completion(.failure(error))
                monitor.cancel()
            }
        }
        monitor.start(queue: queue)
        
        var request = URLRequest(url: link)
        request.timeoutInterval = 15
        
        placeholder(true)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            monitor.cancel()
            placeholder(false)
            self?.activeTasks.removeValue(forKey: normalizedUrl)
            
            if let error = error as? URLError {
                if error.code == .cancelled {
                    return
                }
                if error.code == .timedOut {
                    print("Request timed out: \(normalizedUrl). Retrying...")
                    self?.retryRequest(url: link, saveKeys: normalizedUrl as NSString, attempt: 1, completion: completion)
                    return
                }
            }
            
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                let error = error ?? ErrorAPI.invalidImageData
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }
            
            self?.cache.setObject(image, forKey: normalizedUrl as NSString, cost: data.count)
            
            self?.cache.setObject(image, forKey: normalizedUrl as NSString, cost: data.count)
            
            DispatchQueue.main.async(execute: {
                completion(.success(image))
                URLCache.shared.removeCachedResponse(for: request)
            })
        }
        
        activeTasks[normalizedUrl] = task
        completionTask(task)
        
        operationQueue.addOperation {
            task.resume()
        }
    }
    
    private func retryRequest(url: URL, saveKeys: NSString, attempt: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard attempt <= 3 else {
            let error = ErrorAPI.maxRetriesReached
            completion(.failure(error))
            return
        }
        
        let delay = pow(2.0, Double(attempt))
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: { [weak self] in
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Retry attempt \(attempt) failed: \(error)")
                    self?.retryRequest(url: url, saveKeys: saveKeys, attempt: attempt + 1, completion: completion)
                } else if let data = data, let image = UIImage(data: data) {
                    //                    let normalizedUrl = url.absoluteString
                    let resizedImage = image.resizedWithAspectFit(maxWidth: 1920, maxHeight: 1080) ?? image
                    self?.cache.setObject(resizedImage, forKey: saveKeys as NSString, cost: data.count)
                    DispatchQueue.main.async {
                        completion(.success(image))
                    }
                } else {
                    let error = ErrorAPI.invalidImageData
                    completion(.failure(error))
                }
            }
            self?.operationQueue.addOperation {
                task.resume()
            }
        })
    }
    
    func cancelDownload(url: String) {
        guard let normalizedUrl = URL(string: url)?.absoluteString else { return }
        if let task = activeTasks[normalizedUrl] {
            task.cancel()
            activeTasks.removeValue(forKey: normalizedUrl)
        }
    }
}
