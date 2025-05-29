//
//  ImageGridCell.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import SwiftUI

struct ImageGridCell: View {
    
    enum ImageLoadState {
        case idle
        case loading
        case success(UIImage)
        case failure(Error)
    }
    
    let photoURL: URL?
    @State private var imageState: ImageLoadState = .idle
    @State private var task: Task<Void, Never>? = nil
    
    var body: some View {
        GeometryReader { geometry in
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
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .border(Color.black.opacity(0.1))
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
            .padding(30)
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
            .padding(30)
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
        guard let url = photoURL,
              let scheme = url.scheme,
              !scheme.isEmpty else {
            return
        }
        imageState = .loading
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
