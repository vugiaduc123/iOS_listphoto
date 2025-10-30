//
//  SearchBarMultiplexer+Combine.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//

import UIKit
import Combine

class SearchBarDelegateMultiplexer: NSObject, UISearchBarDelegate, UITextFieldDelegate {
    private var searchBarDelegates: [UISearchBarDelegate] = []
    private var textFieldDelegates: [UITextFieldDelegate] = []
    
    // MARK: - Register delegates
    func addSearchBarDelegate(_ delegate: UISearchBarDelegate) {
        searchBarDelegates.append(delegate)
    }
    
    func addTextFieldDelegate(_ delegate: UITextFieldDelegate) {
        textFieldDelegates.append(delegate)
    }
    
    // MARK: - UISearchBarDelegate forwarding
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarDelegates.forEach {
            $0.searchBar?(searchBar, textDidChange: searchText)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarDelegates.forEach {
            $0.searchBarTextDidEndEditing?(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarDelegates.forEach {
            $0.searchBarCancelButtonClicked?(searchBar)
        }
    }
    
    // MARK: - UITextFieldDelegate forwarding
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Nếu bất kỳ delegate nào return false → chặn
        return textFieldDelegates.allSatisfy {
            $0.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var shouldReturn = true
        textFieldDelegates.forEach {
            shouldReturn = shouldReturn && ($0.textFieldShouldReturn?(textField) ?? true)
        }
        return shouldReturn
    }
}
