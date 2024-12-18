//
//  PhotoManager.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit
import Network
class PhotoManager {
    static var shared = PhotoManager()
    func getApiPhoto(completion: @escaping ([PhotoModel]) -> Void) {
        let result = PhotoAPI(page: 1, limit: 100)
        result.execute { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let err):
                print("API Called failed with error \(err.localizedDescription)")
            }
        }
    }

    func getLoadMore(page: Int, limit: Int, completion: @escaping ([PhotoModel]) -> Void) {
        let result = PhotoAPI(page: page, limit: limit)
        result.execute { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let err):
                print("API Called failed with error \(err.localizedDescription)")
            }
        }
    }

    func adjustCacheSize() {
        let urlCache = URLCache.shared
        // Đặt lại dung lượng bộ nhớ cache và bộ nhớ đĩa
        urlCache.memoryCapacity = 50 * 1024 * 1024  // 50MB for cache 
        urlCache.diskCapacity = 200 * 1024 * 1024  // 200MB cache on disk
        print("Cache size adjusted.")
    }

    func downLoad(url: String, completionTask: @escaping ( (URLSessionDataTask) -> Void), placeHolder: @escaping((Bool) -> Void), completion: @escaping((Result<UIImage, Error>) -> Void)) {
        adjustCacheSize()
        guard let link = URL(string: url) else {
            fatalError("Error Url Link...")
        }
        var task: URLSessionDataTask?
        let monitor = NWPathMonitor()
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 3
        let session = URLSession(configuration: configuration)
        var request = URLRequest(url: link)
        request.timeoutInterval = 10
        placeHolder(true)
        DispatchQueue.global(qos: .background).async {
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    print("Connected to the internet")
                } else {
                    let err = "No internet connection"
                    completion(.failure(err as! Error))
                    return
                }
            }
            task = session.dataTask(with: request) { data, response, error in
                placeHolder(false)
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else {
                    if let error = error as? URLError, error.code == .timedOut {
                        print("Request timed out. Retrying... attempts left.\(error.localizedDescription)")
                        self.retryRequest(url: link) { result in
                            switch result {
                            case .success(let image):
                                DispatchQueue.main.async {
                                    completion(.success(((image))))
                                    URLCache.shared.removeCachedResponse(for: request)
                                }
                            case .failure(let err):
                                URLCache.shared.removeCachedResponse(for: request)
                                completion(.failure(err))
                                return
                            }
                        }
                    }
                    if let err = error{
                        completion(.failure(err))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            }
            if let task = task {
                completionTask(task)
            }
            task?.resume()
        }
    }

    func retryRequest(url: URL, attempt: Int = 1, completion: @escaping((Result<UIImage, Error>) -> Void)) {
        guard attempt <= 3 else {
            let errorString: String = "Maximum retry attempts reached."
            let error: Error = errorString as! Error  // This will throw the error
            completion(.failure(error))
            return
        }

        let delay = pow(2.0, Double(attempt))
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Retry \(attempt) failed: \(error.localizedDescription)")
                    self.retryRequest(url: url, attempt: attempt + 1, completion: { result in })
                } else if let data = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        completion(.success(((image ?? UIImage(named: "loading"))!)))
                    }
                }
            }
            task.resume()
        }
    }
}

