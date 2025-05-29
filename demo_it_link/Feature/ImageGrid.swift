//
//  ImageGrid.swift
//  demo_it_link
//
//  Created by DmitrySK on 27.05.2025.
//

import SwiftUI
import Combine

struct ImageGrid: View {
    
    let data: [ImageRef]
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    @State private var currentScale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems(), spacing: 0) {
                ForEach(data) { imageRef in
                    ImageGridCell(photoURL: imageRef.url)
                }
            }
            .animation(.easeInOut, value: currentScale)
           
        }
        .simultaneousGesture(
            MagnifyGesture()
                .onEnded { value in
                    let newValue = currentScale * value.magnification
                    currentScale = min(max(newValue, minScale), maxScale)
                }
        )
    }
    
    func gridItems() -> [GridItem] {
        let min: CGFloat = 120 * currentScale
        let item = GridItem(.adaptive(minimum: min, maximum: 300), spacing: 2)
        return [item]
    }
}

#Preview {
    ImageGrid(data: ImageRef.previewArray())
}

#Preview(traits: .landscapeLeft) {
    ImageGrid(data: ImageRef.previewArray())
}
