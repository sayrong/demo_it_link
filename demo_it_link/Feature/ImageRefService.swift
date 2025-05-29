//
//  ImageRefService.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import Foundation

protocol ImageRefServiceProtocol {
    func getImageRefs() async throws -> [ImageRef]
}

class ImageRefService: ImageRefServiceProtocol {
    
    let repository = ImageRefRepository()
    
    func getImageRefs() async throws -> [ImageRef] {
        let sourceFile = try await repository.getSourceFile()
        let imageRefs = try parseFile(source: sourceFile)
        return imageRefs
    }
    
    func parseFile(source: URL) throws -> [ImageRef] {
        let fileContent = try String(contentsOf: source, encoding: .utf8)
        return fileContent
            .components(separatedBy: .newlines)
            .map({ line in
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let url = URL(string: trimmedLine)
                return ImageRef(url: url)
            })
    }
}
