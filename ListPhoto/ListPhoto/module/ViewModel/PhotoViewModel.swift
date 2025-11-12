//
//  PhotoViewModel.swift
//  ListPhoto
//
//  Created by Vũ Đức on 16/12/24.
//

import Foundation
import UIKit
import CoreData
class PhotoViewModel {
    let navigator: PhotoNavigator
    let rest = PhotoManager.shared
    init(navigator: PhotoNavigator) {
        self.navigator = navigator
    }
    var isLoadIndicator:Bool = false
    var page = 0
    let limitItem = 10
    var limitLoad = 15
    var limit = 2
    var listPhoto:[PhotoModel] = []
    var filteredData:[PhotoModel] = []
//    let imageCache = CustomCache<NSString, UIImage>()
//    var activeTasks: [IndexPath :URLSessionTask] = [:]
    let downloader = ImageDownloader()
    
    // MARK: API
    func getlistPhoto(placeHolder: @escaping(Bool) -> Void ) {
        placeHolder(true)
        rest.getApiPhoto { data in
            placeHolder(false)
            self.listPhoto = data
        }
    }

    func getLoadMore(page: Int, limit: Int, placeHolder: @escaping(Bool) -> Void ) {
        placeHolder(true)
        rest.getLoadMore(page: page, limit: limit) { data in
            self.isLoadIndicator = false
            placeHolder(false)
            for i in data {
                self.listPhoto.append(i)
            }
        }
    }
    // MARK: Logic

    func prefixNumber(number: Int) -> Int{
        if number.description.count > 3 {
            return Int(String(number).prefix(3))!
        }
        return number
    }
    // MARK: Helper Function to Remove '&amp;' from String

    func removeAmpersandEntity(from string: String, completion: (Bool) -> Void) -> String {
        let cleanString = string.replacingOccurrences(of: "&amp;", with: "").replacingOccurrences(of: "emoji", with: "")
        if string != cleanString {
            completion(true)
        }
        return cleanString
    }

    func removeDiacritics(from string: String, completion: (Bool) -> Void) -> String {
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

    func filterSearchBar(filter: Bool, tapCancel: Bool, stringFilter: String) {
        if tapCancel {
            if filteredData.count != 0 {
                listPhoto.removeAll()
                listPhoto = filteredData
                filteredData.removeAll()
            }
        }else {
            if filter == false {
                listPhoto.removeAll()
                listPhoto = filteredData
                filteredData.removeAll()
            }else{
                if filteredData.count == 0 {
                    filteredData = listPhoto
                }else {
                    listPhoto = filteredData
                }
                let newArray = listPhoto.filter { $0.author.lowercased().contains(stringFilter.lowercased()) }
                listPhoto.removeAll()
                listPhoto = newArray
            }
        }
    }

    // MARK: Destination Link
    func navigateToEvent() {
        navigator.navigateToEventScreen()
    }

    func indicatorView(frame: CGRect) -> UIView {
        let containView = UIView()
        containView.frame = frame
        containView.backgroundColor = .black.withAlphaComponent(0.5)
        let customIndicator = CustomLoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        customIndicator.center = containView.center
        containView.addSubview(customIndicator)
        return containView
    }
}


