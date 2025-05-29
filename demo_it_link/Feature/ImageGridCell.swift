//
//  ImageGridCell.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import SwiftUI

struct ImageGridCell: View {
    
    enum LoadState {
        case idle
        case loading
        case success(UIImage)
        case failure(Error)
    }
    
    let photoURL: URL?
    @State private var imageState: LoadState = .loading
    @State private var task: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            switch imageState {
            case .idle:
                placeholder()
            case .loading:
                loadingView()
            case .success(let image):
                thumbnail(image)
            case .failure(_):
                retryView()
            }
        }
        .frame(width: 200, height: 200)
        .border(Color.gray.opacity(0.2))
        .clipped()
        .onAppear {
            task?.cancel()
            Task {
                await loadImage()
            }
        }
        .onDisappear {
            task?.cancel()
        }
    }
    
    private func placeholder() -> some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .opacity(0.5)
    }
    
    private func thumbnail(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
    }
    
    private func retryView() -> some View {
        Image(systemName: "arrow.counterclockwise")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .opacity(0.5)
            .onTapGesture {
                Task {
                    await loadImage()
                }
            }
    }
    
    private func loadingView() -> some View {
        ProgressView()
    }
    
    private func loadImage() async {
        guard let url = photoURL else { return }
        do {
            let image = try await ImageLoader.shared.loadImage(from: url, type: .thumbnail)
            imageState = .success(image)
        } catch {
            imageState = .failure(error)
        }
    }
}

#Preview {
    ImageGridCell(photoURL: nil)
}
