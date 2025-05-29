//
//  AppCoordinator.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//
import SwiftUI

final class AppCoordinator: ObservableObject {
    
    enum State {
        case idle
        case loading
        case loaded([ImageRef])
        case failed(Error)
    }
    
    @Published var state: State = .idle
    
    private let networkMonitor: NetworkMonitorProtocol
    private let imageRefService: ImageRefServiceProtocol
    
    init() {
        self.networkMonitor = NetworkMonitor()
        self.imageRefService = ImageRefService()
        bindObserver()
        startDownload()
    }
    
    func startDownload() {
        Task {
            state = .loading
            do {
                let result = try await imageRefService.getImageRefs()
                await MainActor.run {
                    state = .loaded(result)
                }
            } catch {
                await MainActor.run {
                    state = .failed(error)
                }
            }
        }
    }
    
    private func bindObserver() {
        self.networkMonitor.onConnectionStatusChanged = { [weak self] isConnected in
            self?.observeNetwork(isConnected)
        }
    }
    
    private func observeNetwork(_ isConnected: Bool) {
        guard isConnected else { return }
        
        if case .failed(_) = self.state {
            self.startDownload()
        }
    }
    
    @ViewBuilder
    var rootView: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
        case .failed(let error):
            Text(error.localizedDescription)
        case .loaded(let imageRefs):
            ImageGrid(data: imageRefs)
        }
    }
}
