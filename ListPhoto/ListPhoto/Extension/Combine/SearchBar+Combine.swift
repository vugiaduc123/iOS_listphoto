//
//  SearchBar+Combine.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//

import UIKit
import Combine

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
