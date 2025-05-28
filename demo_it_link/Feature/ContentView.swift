//
//  ContentView.swift
//  demo_it_link
//
//  Created by DmitrySK on 27.05.2025.
//

import SwiftUI
import Combine


struct ImageGrid: View {
    
    let data = (1...100).map { "Item \($0)" }

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(data, id: \.self) { item in
                    Text(item)
                        .border(.yellow)
                }
            }
            .padding(.horizontal)
        }
        //.frame(maxHeight: 300)
    }
}

#Preview {
    ImageGrid()
}

#Preview(traits: .landscapeLeft) {
    ImageGrid()
}

//class ContentViewModel: ObservableObject {
//    
//    enum State {
//        case idle
//        case loading
//        case loaded([ImageRef])
//        case failed(Error)
//    }
//    
//    @Published var state: State = .idle
//    
//    private let networkMonitor: NetworkMonitorProtocol
//    private let imageRefService: ImageRefServiceProtocol
//    
//    init(networkMonitor: NetworkMonitorProtocol,
//         imageRefService: ImageRefServiceProtocol) {
//        self.networkMonitor = networkMonitor
//        self.imageRefService = imageRefService
//        bindObserver()
//    }
//    
//    func startDownload() {
//        Task {
//            state = .loading
//            do {
//                let result = try await imageRefService.getImageRefs()
//                state = .loaded(result)
//            } catch {
//                state = .failed(error)
//            }
//        }
//    }
//    
//    private func bindObserver() {
//        self.networkMonitor.onConnectionStatusChanged = { [weak self] isConnected in
//            self?.observeNetwork(isConnected)
//        }
//    }
//    
//    private func observeNetwork(_ isConnected: Bool) {
//        guard isConnected else { return }
//        
//        if case .failed(_) = self.state {
//            self.startDownload()
//        }
//    }
//}
//
//struct ContentView: View {
//    
//    @StateObject var viewModel = ContentViewModel()
//    
//    var body: some View {
//        VStack {
//            foo()
//        }
//        .padding()
//        .onAppear {
//            viewModel.startDownload()
//        }
//    }
//    
//    @ViewBuilder
//    func foo() -> some View {
//        switch viewModel.state {
//        case .idle:
//            Text("Get started")
//        case .loading:
//            Text("Loading")
//        case .loaded(let array):
//            List {
//                ForEach(array, id: \.self) { imageRef in
//                    Text(imageRef.url.absoluteString)
//                }
//            }
//        case .failed(let error):
//            Text(error.localizedDescription)
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}

