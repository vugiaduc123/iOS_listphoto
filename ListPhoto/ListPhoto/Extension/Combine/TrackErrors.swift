//
//  TrackErros.swift
//  ListPhoto
//
//  Created by Đức Vũ on 21/9/25.
//

struct TrackErrors<T: Hashable> {
    let enumError: T
    let error: Error
    var messageError: String { "\(enumError): \(error.localizedDescription)" }
}
