//
//  ImageDetails.swift
//  demo_it_link
//
//  Created by DmitrySK on 29.05.2025.
//

import SwiftUI

struct ImageDetails: View {
    
    let data: [ImageRef]
    
    @State private var isSharing = false
    @State private var startIndex: Int = 0
    @State private var currentScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    var onClose: (() -> Void)? = nil
    
    init(data: [ImageRef], startIndex: Int = 0, onClose: (() -> Void)? = nil) {
        self.data = data
        _startIndex = State(initialValue: startIndex)
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $startIndex) {
                ForEach(data.indices, id: \.self) { idx in
                    AsyncImageView(photoURL: data[idx].url, mode: .detail)
                        .tag(idx)
                        .scaleEffect(currentScale * gestureScale)
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
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            HStack {
                menuWithShare()
                Spacer()
                closeButton()
            }
        }
        .background(Color(.secondarySystemBackground))
    }
    
    @ViewBuilder
    private func menuWithShare() -> some View {
        if let link = data[startIndex].url,
            let scheme = link.scheme, !scheme.isEmpty  {
            Menu {
                Button {
                    isSharing = true
                } label: {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }

                Button {
                    UIApplication.shared.open(link)
                } label: {
                    Label("Открыть в браузере", systemImage: "safari")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 25))
                    .foregroundColor(.secondary)
                    .padding()
            }
            .sheet(isPresented: $isSharing) {
                ActivityView(activityItems: [link])
            }
        }
    }
    
    private func closeButton() -> some View {
        Button {
            onClose?()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

#Preview {
    ImageDetails(data: ImageRef.previewArray())
}
