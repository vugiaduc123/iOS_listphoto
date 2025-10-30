//
//  NetworkMonitor.swift
//  ListPhoto
//
//  Created by Vũ Đức on 18/12/24.
//

import Foundation
import Network
import Combine

enum NetworkStatus: String {
    case disconnected     // ❌ Không có kết nối
    case weakConnection   // ⚠️ Mạng yếu, chậm, thường là cellular
    case strongConnection // ✅ Mạng ổn định, thường là Wi-Fi hoặc Ethernet
    case normal
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private let subject = CurrentValueSubject<NetworkStatus, Never>(.normal)
    var publisher: AnyPublisher<NetworkStatus, Never> {
        subject
            .removeDuplicates()
            .dropFirst(1)
            .eraseToAnyPublisher()
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let status: NetworkStatus
            if path.status == .unsatisfied {
                status = .disconnected
            } else if path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet) {
                status = .strongConnection
            } else if path.usesInterfaceType(.cellular) {
                status = .weakConnection
            } else {
                status = .weakConnection
            }
            
            self.subject.send(status)
        }
        monitor.start(queue: queue)
    }
}
