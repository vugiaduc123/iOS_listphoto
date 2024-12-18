//
//  APIOperation.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import Network

typealias APIClient = APIRequest & APIOperation

protocol APIOperation {
    associatedtype Model: Codable
    func execute(completion: @escaping (Result<Model, Error>) -> Void )
}

extension APIOperation where Self: APIRequest {
    func execute(completion: @escaping (Result<Model, Error>) -> Void) {
        displayInformation()
        let monitor = NWPathMonitor()
        let session = URLSession.shared
        let url = fullURL
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to the internet")
            } else {
                let err = "No internet connection"
//                completionMonitor(.noInternet)
                completion(.failure(err as! Error))
                return
            }
        }
        let task = session.dataTask(with: request) { data, response, error in

            if let error = error as? URLError, error.code == .timedOut {
                debugPrint(error)
                print("Request timed out. Retrying... attempts left.")
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }

            if error != nil || data == nil {
                print("Client error!")
                URLCache.shared.removeCachedResponse(for: request)
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                URLCache.shared.removeCachedResponse(for: request)
                return
            }

            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                URLCache.shared.removeCachedResponse(for: request)
                return
            }

            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Model.self, from: data!)
                completion(.success(decoded))
                URLCache.shared.removeCachedResponse(for: request)
            } catch {
                debugPrint(error)
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
            }
        }
        task.resume()
    }
}


