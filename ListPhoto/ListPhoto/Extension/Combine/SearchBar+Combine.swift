//
//  SearchBar+Combine.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//

import UIKit
import Combine
//
//extension UISearchBar {
//    var searchEventsPublisher: SearchEventsPublisher {
//        return SearchEventsPublisher(searchBar: self)
//    } // Publisher cho cả textDidChange và endEditing
//    
//    struct SearchEventsPublisher: Publisher {
//        // Output là enum để phân biệt các sự kiện
//        enum Event {
//            case textDidChange(String?)
//            case endEditing
//            case cancelButtonClicked
//        }
//        
//        typealias Output = Event // typealias
//        typealias Failure = Never
//        
//        let searchBar: UISearchBar
//        
//        func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Event {
//            let subscription = SearchEventsSubscription(subscriber: subscriber, searchBar: searchBar)
//            subscriber.receive(subscription: subscription)
//        }
//        
//        private final class SearchEventsSubscription<S: Subscriber>: NSObject, Subscription, UISearchBarDelegate where S.Input == SearchEventsPublisher.Event, S.Failure == Never {
//            private var subscriber: S?
//            private weak var searchBar: UISearchBar?
//            
//            init(subscriber: S, searchBar: UISearchBar) {
//                self.subscriber = subscriber
//                self.searchBar = searchBar
//                
//                super.init()
//                self.searchBar?.delegate = self
//            }
//            
//            func request(_ demand: Subscribers.Demand) { }
//            
//            func cancel() {
//                subscriber = nil
//                searchBar?.delegate = nil
//            }
//            
//            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//                _ = subscriber?.receive(.textDidChange(searchText))
//            }
//            
//            func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//                _ = subscriber?.receive(.endEditing)
//            }
//            
//            func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//                _ = subscriber?.receive(.cancelButtonClicked)
//            }
//        }
//    }
//}

extension Notification.Name {
    static let searchBarCancelButtonClicked = Notification.Name("SearchBarCancelButtonClicked")
}

extension UISearchBar {
    enum SearchEvent {
        case textDidChange(String)
        case endEditing
        case cancelButtonClicked
    }

    var searchEventsPublisher: AnyPublisher<SearchEvent, Never> {
        let textPublisher = NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self.searchTextField
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .map { SearchEvent.textDidChange($0) }

        let endEditingPublisher = NotificationCenter.default.publisher(
            for: UITextField.textDidEndEditingNotification,
            object: self.searchTextField
        )
        .map { _ in SearchEvent.endEditing }

        let cancelPublisher = NotificationCenter.default.publisher(
            for: Notification.Name("SearchBarCancel"),
            object: self
        )
        .map { _ in SearchEvent.cancelButtonClicked }

        return Publishers.Merge3(textPublisher, endEditingPublisher, cancelPublisher)
            .eraseToAnyPublisher()
    }
}
