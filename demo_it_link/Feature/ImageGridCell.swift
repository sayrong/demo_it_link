//
//  ImageGridCell.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import SwiftUI

struct ImageGridCell: View {
    
    let photoURL: URL?
    @State private var image: UIImage?
    @State private var task: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray
                ProgressView()
            }
        }
        .frame(width: 100, height: 100)
        .clipped()
    }
}

#Preview {
    ImageGridCell(photoURL: nil)
}
