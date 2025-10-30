import Foundation
import UIKit
import Combine

class PhotoViewModel: ViewModelType {
    
    private let useCase: PhotoUseCase
    
    var listPhoto: [PhotoEntity] = []
    private var filteredData: [PhotoEntity] = []

    private var page = 1
    private var limit = 100
    var isFiltering: Bool = false
    
    let downloader = ImageDownloader.shared
    
    init(useCase: PhotoUseCase) {
        self.useCase = useCase
    }
    
    let errorSubject = PassthroughSubject<TrackErrors<PhotoResultType>, Never>()
    let loadingSubject = CurrentValueSubject<Bool, Never>(false)
    let photosSubject = CurrentValueSubject<[PhotoEntity], Never>([])
    let pageInfoSubject = CurrentValueSubject<String,Never>("0/0")
    
    func transform(input: Input) -> Output {
        // Initial fetch
        let initial = initialTrigger(input: input)
        // Search (local filter, no API)
        let search = searchText(input: input)
        // Refresh (shuffle local data, with delay)
        let refresh = refreshTrigger(input: input)
        // Load more
        let loadMore = loadMoreTrigger(input: input)
        
        let inputTrigger = Publishers.MergeMany(initial, search, refresh, loadMore).eraseToAnyPublisher()
        
        return Output(
            result: inputTrigger,
            loading: loadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher(),
            pageInfo: pageInfoSubject.eraseToAnyPublisher()
        )
    }
}
// MARK: - API
extension PhotoViewModel {
    private func fetchPhotos() -> AnyPublisher<[PhotoEntity], DomainAPIsError> {
        useCase.fetchPhotos(page: page, limit: limit)
            .eraseToAnyPublisher()
    }
    
    private func getLoadMore(page: Int, limit: Int) -> AnyPublisher<[PhotoEntity], DomainAPIsError> {
        useCase.fetchPhotos(page: page, limit: limit)
            .eraseToAnyPublisher()
    }
}

// MARK: - Input Trigger
extension PhotoViewModel {
    private func searchText(input: Input) -> AnyPublisher<PhotoResult, Never> {
        return input.searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .flatMap { [weak self] (searchText, endSearch) -> AnyPublisher<[PhotoEntity], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                self.performSearch(authorString: searchText,
                                   endSearch: endSearch)
                return Just(self.listPhoto).eraseToAnyPublisher()
            }
            .map { items in
                PhotoResult(type: .search(self.isFiltering),
                            items: items)
            }
            .eraseToAnyPublisher()
    }
    
    private func initialTrigger(input: Input) -> AnyPublisher<PhotoResult, Never> {
        loadingSubject.send(true)
        return input.initialFetch
            .flatMap { [weak self] _ -> AnyPublisher<[PhotoEntity], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchPhotos()
                    .handleEvents(receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        self.loadingSubject.send(false)
                        if case .failure(let error) = completion {
                            self.errorSubject.send(TrackErrors(enumError: .initial, error: error))
                        }
                    })
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .map { items in
                PhotoResult(type: .initial, items: items)
            }
            .handleEvents(receiveOutput: { [weak self] result in
                guard let self = self else { return }
                self.listPhoto = result.items
                pageInfoSubject.send("0/\(result.items.count)")
            })
            .eraseToAnyPublisher()
    }
    
    private func refreshTrigger(input: Input) -> AnyPublisher<PhotoResult, Never> {
        return input.refresh
            .flatMap { [weak self] _ -> AnyPublisher<[PhotoEntity], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                loadingSubject.send(true)
                return Just(self.listPhoto)
                    .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .map { items -> [PhotoEntity] in
                var shuffled = items
                shuffled.shuffle()
                return shuffled
            }
            .map { items in
                PhotoResult(type: .refresh, items: items)
            }
            .handleEvents(receiveOutput: { [weak self] result in
                guard let self = self else { return }
                self.listPhoto = result.items
                pageInfoSubject.send("0/\(result.items.count)")
                loadingSubject.send(false)
            }).eraseToAnyPublisher()
    }
    
    private func loadMoreTrigger(input: Input) -> AnyPublisher<PhotoResult, Never> {
        return input.loadMore
           .filter { [weak self] _ in
               guard let self = self else { return false }
               return !self.isFiltering 
           }
           .flatMap { [weak self] _ -> AnyPublisher<[PhotoEntity], Never> in
               guard let self = self else { return Just([]).eraseToAnyPublisher() }
               loadingSubject.send(true)
               let nextPage = self.page + 1
               return self.getLoadMore(page: nextPage, limit: self.limit)
                   .handleEvents(receiveCompletion: { [weak self] completion in
                       guard let self = self else { return }
                       loadingSubject.send(false)
                       if case .failure(let error) = completion {
                           errorSubject.send(TrackErrors(enumError: .loadMore(0,0), error: error))
                       }
                   })
                   .replaceError(with: [])
                   .eraseToAnyPublisher()
           }
           .map { [weak self] items in
               guard let self = self else { return PhotoResult(type: .loadMore(0, 0), items: []) }
               let firtIndex = self.listPhoto.count
               let endIndex = firtIndex + items.count
               return PhotoResult(type: .loadMore(firtIndex, endIndex), items: items)
           }
           .handleEvents(receiveOutput: { [weak self] result in
               guard let self = self else { return }
               self.listPhoto.append(contentsOf: result.items)
               self.page += 1
               pageInfoSubject.send("\(self.listPhoto.count)")
           }).eraseToAnyPublisher()
    }
}

// MARK: - Logic
extension PhotoViewModel {
    func prefixNumber(number: Int) -> Int {
        if number.description.count > 3 {
            return Int(String(number).prefix(3))!
        }
        return number
    }
    
    func removeAmpersandEntity(from string: String, completion: @escaping (Bool) -> Void) -> String {
        let cleanString = string
            .filter { $0 != "&" } // bỏ &
            .filter {
                guard let scalar = $0.unicodeScalars.first else { return false }
                return scalar.properties.isEmoji == false // bỏ emoji
            }
        if string != cleanString {
            completion(true)
        }
        return String(cleanString)
    }
    
    func removeDiacritics(from string: String, completion: @escaping (Bool) -> Void) -> String {
        let diacritics: [Character: Character] = [
            "á": "a", "à": "a", "ả": "a", "ã": "a", "ạ": "a",
            "ă": "a", "ắ": "a", "ằ": "a", "ẳ": "a", "ẵ": "a", "ặ": "a",
            "â": "a", "ấ": "a", "ầ": "a", "ẩ": "a", "ẫ": "a", "ậ": "a",
            "é": "e", "è": "e", "ẻ": "e", "ẽ": "e", "ẹ": "e",
            "ê": "e", "ế": "e", "ề": "e", "ể": "e", "ễ": "e", "ệ": "e",
            "í": "i", "ì": "i", "ỉ": "i", "ĩ": "i", "ị": "i",
            "ó": "o", "ò": "o", "ỏ": "o", "õ": "o", "ọ": "o",
            "ô": "o", "ố": "o", "ồ": "o", "ổ": "o", "ỗ": "o", "ộ": "o",
            "ơ": "o", "ớ": "o", "ờ": "o", "ở": "o", "ỡ": "o", "ợ": "o",
            "ú": "u", "ù": "u", "ủ": "u", "ũ": "u", "ụ": "u",
            "ư": "u", "ứ": "u", "ừ": "u", "ử": "u", "ữ": "u", "ự": "u",
            "ý": "y", "ỳ": "y", "ỷ": "y", "ỹ": "y", "ỵ": "y",
            "đ": "d"
        ]
        let removeTelex = String(string.map { diacritics[$0] ?? $0 })
        if string != removeTelex {
            completion(true)
        }
        return removeTelex
    }
    
    func performSearch(authorString: String, endSearch: Bool) {
        if endSearch {
            resetFilter()
            return
        }
        
        if filteredData.isEmpty {
            filteredData = listPhoto
        }
        
        listPhoto = filteredData.filter{
            $0.author.lowercased().contains(authorString.lowercased())
        }
        
        if listPhoto.count == 0 {
            pageInfoSubject.send("0/0")
        } else {
            pageInfoSubject.send("0/\(listPhoto.count)")
        }
        
        isFiltering = true
    }
    
    func resetFilter() {
        if !filteredData.isEmpty {
            listPhoto = filteredData
            filteredData.removeAll()
            isFiltering = false
        }
    }
}

extension PhotoViewModel {
    struct Input {
        let initialFetch: AnyPublisher<Void, Never>
        let refresh: AnyPublisher<Void, Never>
        let loadMore: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<(String, Bool), Never>
    }
    struct Output {
        let result: AnyPublisher<PhotoResult, Never>
        let loading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<TrackErrors<PhotoResultType>, Never>
        let pageInfo: AnyPublisher<String, Never>
    }
    
    enum PhotoResultType: Hashable {
        case initial
        case refresh
        case loadMore(Int, Int)
        case search(Bool) // thieu dieu kien bat dau vaf ket thuc
    }
    
    struct PhotoResult {
        let type: PhotoResultType
        let items: [PhotoEntity]
    }
}
