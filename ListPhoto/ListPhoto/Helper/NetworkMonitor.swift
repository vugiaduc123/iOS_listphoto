//
//  NetworkMonitor.swift
//  ListPhoto
//
//  Created by Vũ Đức on 18/12/24.
//

import Foundation

import Network

<<<<<<< HEAD
enum NetworkStatus: String {
    case disconnected
    case weakConnection
    case strongConnection
    case normal
}

final class NetworkMonitor {
=======
class NetworkMonitor {
>>>>>>> 3404a3230b2633a709d53b397211244b9c4e1f7e
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
<<<<<<< HEAD

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
=======
    private(set) var isConnected: Bool = false
    private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {}

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.connectionType = self?.getConnectionType(path) ?? .unknown

            if self?.isConnected == true {
                print("Connected to the internet: \(self?.connectionType ?? .unknown)")
>>>>>>> 3404a3230b2633a709d53b397211244b9c4e1f7e
            } else {
                print("No connected to the internet")
            }
<<<<<<< HEAD

            self.subject.send(status)
=======
>>>>>>> 3404a3230b2633a709d53b397211244b9c4e1f7e
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
}
