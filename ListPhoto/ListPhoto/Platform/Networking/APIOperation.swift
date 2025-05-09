//
//  APIOperation.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//
import Foundation
import Network
import Combine

typealias APIClient = APIRequest & APIOperation

protocol APIOperation {
    associatedtype Model: Codable
    func execute(method: HTTPMethod, parameters: [String: Any]?, completion: @escaping (Result<Model, Error>) -> Void)
}

extension APIOperation where Self: APIRequest {
    func execute(method: HTTPMethod, parameters: [String: Any]?, completion: @escaping (Result<Model, Error>) -> Void) {
        displayInformation()
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to the internet")
            } else {
                let err = "No internet connection"
                completion(.failure(err as! Error))
                return
            }
        }
        monitor.start(queue: queue)
        
        let url = fullURL(with: method == .get ? parameters : nil)
        var request = URLRequest(url: url)
        
        request = request
            .getMethod(method.rawValue)
            .setHeader(headers ?? environment.headers)
            .setTimeout(30)
        
        if method != .get, let params = parameters {
            request = configureBody(for: request, with: params)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as? URLError, error.code == .timedOut {
                debugPrint(error)
                print("Request timed out.")
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }
            
            guard error == nil, let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Client error"])
                print("Client error!")
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                print("Server error!")
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Wrong MIDI type"])
                print("Wrong MIME type!")
                completion(.failure(error))
                URLCache.shared.removeCachedResponse(for: request)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Model.self, from: data)
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
    
    private func configureBody(for request: URLRequest, with parameters: [String: Any]) -> URLRequest {
        var updatedRequest = request
        do {
            updatedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            updatedRequest = updatedRequest.setHeader(["Content-Type": "application/json"])
        } catch {
            fatalError("Error parse parameters to JSON")
        }
        return updatedRequest
    }
}

extension URLRequest {
    func getMethod(_ method: String) -> URLRequest {
        var request = self
        request.httpMethod = method
        return request
    }
    
    func setHeader(_ headers: [String: String]?) -> URLRequest {
        var request = self
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
    
    func setTimeout(_ timeout: TimeInterval) -> URLRequest {
        var request = self
        request.timeoutInterval = timeout
        return request
    }
}
