import Foundation
import UIKit
import Network
import Combine

class ImageDownloader {
    static let shared = ImageDownloader()

    private let session: URLSession
    private let cache: NSCache<NSString, UIImage>

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 3
        let urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024,
                                diskCapacity: 200 * 1024 * 1024,
                                diskPath: "imageCache")
        configuration.urlCache = urlCache
        self.session = URLSession(configuration: configuration)

        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = 300
        self.cache.totalCostLimit = 200 * 1024 * 1024
    }

    func download(input: Input) -> Output {
        let loadingSubject = CurrentValueSubject<Bool, Never>(false)
        let errorSubject = PassthroughSubject<Error, Never>()

        loadingSubject.send(true)

        if let cached = cache.object(forKey: input.url as NSString) {
            let imagePub = Just(cached).eraseToAnyPublisher()
            return Output(
                image: imagePub,
                loading: Just(false).eraseToAnyPublisher(),
                error: Empty().eraseToAnyPublisher()
            )
        }

        guard let url = URL(string: input.url) else {
            errorSubject.send(DomainImageError.invalidURL)
            return Output(
                image: Empty().eraseToAnyPublisher(),
                loading: Just(false).eraseToAnyPublisher(),
                error: errorSubject.eraseToAnyPublisher()
            )
        }

        let publisher = session.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let httpResp = response as? HTTPURLResponse else {
                    throw DomainImageError.invalidResponse
                }

                switch httpResp.statusCode {
                case 200...299: break
                case 400...499: throw DomainImageError.clientError(httpResp.statusCode)
                case 500...599: throw DomainImageError.serverError(httpResp.statusCode)
                default: throw DomainImageError.invalidResponse
                }

                guard let mime = response.mimeType, mime.hasPrefix("image"),
                      let image = UIImage(data: data) else {
                    throw DomainImageError.invalidImageData
                }

                let imageRender = image.renderImage().decodedImage()
                self.cache.setObject(imageRender, forKey: input.url as NSString, cost: data.count)
                return imageRender
            }
            .retry(2)
            .mapError { error -> DomainImageError in
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        return .noInternet
                    case .timedOut:
                        return .timeout
                    default:
                        return .requestFailed(urlError)
                    }
                } else if let domainError = error as? DomainImageError {
                    return domainError
                } else {
                    return .unknown
                }
            }
            .handleEvents(
                receiveCompletion: { completion in
                    loadingSubject.send(false)
                    if case let .failure(error) = completion {
                        errorSubject.send(error)
                    }
                }
            )
            .catch { _ in Empty<UIImage, Never>() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(
            image: publisher,
            loading: loadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}

extension ImageDownloader {
    // MARK: - Input
    struct Input {
        let url: String
    }

    // MARK: - Output
    struct Output {
        let image: AnyPublisher<UIImage, Never>
        let loading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<Error, Never>
    }
}
