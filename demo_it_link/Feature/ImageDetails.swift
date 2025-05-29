//
//  ImageDetails.swift
//  demo_it_link
//
//  Created by DmitrySK on 29.05.2025.
//

import SwiftUI

struct ImageDetails: View {
    
    let data: [ImageRef]
    
    @State private var currentScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    
    var body: some View {
        TabView {
            ForEach(data, id: \.self) { ref in
                AsyncImageView(photoURL: ref.url, mode: .detail)
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
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    ImageDetails(data: ImageRef.previewArray())
}
