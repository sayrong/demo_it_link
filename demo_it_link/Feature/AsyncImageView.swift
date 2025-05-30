//
//  AsyncImageView.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import SwiftUI

struct DetailAsyncImageView: View {
    let photoURL: URL?
    
    var body: some View {
        AsyncImageView(photoURL: photoURL, mode: .detail)
            .frame(maxHeight: .infinity)
            .clipped()
    }
}

struct GridAsyncImageView: View {
    let photoURL: URL?
 
    var body: some View {
        GeometryReader { geometry in
            AsyncImageView(photoURL: photoURL, mode: .grid)
                .frame(width: geometry.size.width, height: geometry.size.width)
                
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }
}

struct AsyncImageView: View {
    
    enum DisplayMode {
        case grid
        case detail
    }
    
    enum ImageLoadState {
        case idle
        case loading
        case success(UIImage)
        case failure(Error)
    }
    
    let photoURL: URL?
    
    let mode: DisplayMode
    @State private var imageState: ImageLoadState = .idle
    @State private var task: Task<Void, Never>? = nil
    @State private var currentScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            switch imageState {
            case .idle:
                placeholder()
            case .loading:
                loadingView()
            case .success(let image):
                presentedImage(image)
            case .failure(_):
                retryView()
            }
        }
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
    
    @ViewBuilder
    private func presentedImage(_ image: UIImage) -> some View {
        if mode == .grid {
            thumbnail(image)
        } else {
            originalImage(image)
        }
    }
    
    private func thumbnail(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    private func originalImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaleEffect(currentScale * gestureScale)
            .aspectRatio(contentMode: .fit)
            .gesture(MagnifyGesture()
                .updating($gestureScale) { value, state, _ in
                    let newValue = currentScale * value.magnification
                    if newValue > minScale && newValue < maxScale {
                        state = value.magnification
                    }
                }
                .onEnded { value in
                    let newValue = currentScale * value.magnification
                    currentScale = min(max(newValue, minScale), maxScale)
                })
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
    
    @MainActor
    private func loadImage() async {
        guard let url = photoURL,
              let scheme = url.scheme,
              !scheme.isEmpty else {
            return
        }
        imageState = .loading
        do {
            let type: ImageType = mode == .grid ? .thumbnail : .original
            let image = try await ImageLoader.shared.loadImage(from: url, type: type)
            imageState = .success(image)
        } catch {
            imageState = .failure(error)
        }
    }
}

#Preview {
    AsyncImageView(photoURL: nil, mode: .grid)
}
