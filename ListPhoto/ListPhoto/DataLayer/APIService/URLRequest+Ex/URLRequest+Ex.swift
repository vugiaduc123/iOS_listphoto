//
//  URLRequest+Ex.swift
//  ListPhoto
//
//  Created by Đức Vũ on 20/10/25.
//

import Foundation

extension URLRequest {
    func getMethod(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue
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
    
    func setJSONBody(_ method: HTTPMethod, with parameters: [String: Any]?) -> URLRequest {
        guard let params = parameters, !params.isEmpty else { return self }
        var request = self

        if method == .get {
            var urlComponents = URLComponents(url: self.url!, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = params.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            request.url = urlComponents?.url
        } else {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                fatalError("SetJSONBody: \(DomainAPIsError.endCodingError)")
            }
        }
        
        return request
    }
}

