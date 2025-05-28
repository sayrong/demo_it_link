//
//  NetworkMonitor.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import Network
import SwiftUI

protocol NetworkMonitorProtocol: AnyObject {
    var onConnectionStatusChanged: ((Bool) -> Void)? { get set }
}

final class NetworkMonitor: NetworkMonitorProtocol {
    var onConnectionStatusChanged: ((Bool) -> Void)?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.onConnectionStatusChanged?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
