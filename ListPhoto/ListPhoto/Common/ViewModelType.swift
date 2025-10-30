//
//  ViewModelType.swift
//  ListPhoto
//
//  Created by Đức Vũ on 19/9/25.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
