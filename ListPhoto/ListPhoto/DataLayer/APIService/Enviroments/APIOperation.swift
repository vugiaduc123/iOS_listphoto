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
    
    var loadingSubject: CurrentValueSubject<Bool, Never> { get }
    var errorSubject:   PassthroughSubject<Error, Never> { get }
    
    func request(method: HTTPMethod, parameters: [String: Any]?) -> AnyPublisher<Model, DomainAPIsError>
}

extension APIOperation where Self: APIRequest {
    func request(method: HTTPMethod, parameters: [String: Any]?) -> AnyPublisher<Model, DomainAPIsError> {
        displayInformation()
        loadingSubject.send(true)
        
        let url = fullURL()
        var request = URLRequest(url: url)
        
        request = request
            .getMethod(method)
            .setHeader(headers ?? environment.headers)
            .setJSONBody(method, with: parameters!)
            .setTimeout(30)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw DomainAPIsError.invalidURL
                }
                
                switch httpResponse.statusCode {
                case 200...299: break
                case 400...499: throw DomainAPIsError.clientError(httpResponse.statusCode)
                case 500...599: throw URLError(.badServerResponse)
                default: throw DomainAPIsError.invalidStatusCode(httpResponse.statusCode)
                }
                
                let application: ConTentType = .json
                guard httpResponse.mimeType == application.rawValue else {
                    throw DomainAPIsError.invalidMinType
                }

                return data
            }
            .retry(2)
            .decode(type: Model.self, decoder: JSONDecoder())
            .mapError { error -> DomainAPIsError in
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        return .noInternet
                    case .timedOut:
                        return .timeout
                    case .cancelled:
                        return .cancelled
                    case .cannotDecodeContentData:
                        return .decodingFailed
                    case .badServerResponse:
                        return .serverError(500)
                    default:
                        return .requestFailed(urlError)
                    }
                } else if let DomainAPIsError = error as? DomainAPIsError {
                    return DomainAPIsError
                } else {
                    return .unknown
                }
            }
            .handleEvents(receiveCompletion: { completion in
                self.loadingSubject.send(false)
                if case let .failure(error) = completion {
                    self.errorSubject.send(error)
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

