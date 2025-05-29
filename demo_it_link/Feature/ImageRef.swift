//
//  Untitled.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import Foundation

struct ImageRef: Hashable, Identifiable {
    let id = UUID()
    var url: URL?
}


extension ImageRef {
    static func previewArray() -> [ImageRef] {
        let data: [ImageRef] = [
            .init(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKMBWXDkh39EwFfxTgsvf-f-IuC_cMHDX1Sg")),
            .init(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWmWDG5z0KEBbc-My7aGzu7vNdzyyVjsu4Vw")),
            .init(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmf84YLb5lqDzJ-fcz-qHJO6Q6Bll7RprXcg")),
            .init(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmOIDvtPWSLzribzOkcHNoBS_csNNr_ITK6Q")),
            .init(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsR-oHmKFQ-etDR6SookjLSuB4tuqycrfDXg"))
        ]
        return data
    }
}
