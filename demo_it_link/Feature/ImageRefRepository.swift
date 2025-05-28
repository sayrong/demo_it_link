//
//  ImageRefRepository.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import SwiftUI

protocol ImageRefRepositoryProtocol {
    func getSourceFile() async throws -> URL
}

class ImageRefRepository: ImageRefRepositoryProtocol {
    
    var inputSource = "https://it-link.ru/test/images.txt"
    private let session: URLSession
    private let fileManager: FileManager
    
    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }
    
    func getSourceFile() async throws -> URL {
        guard let url = URL(string: inputSource) else {
            throw TextFileLoaderErrors.invalidSourceURL
        }
        let fileName = url.lastPathComponent
        let cacheURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = cacheURL.appending(path: fileName, directoryHint: .notDirectory)
        
        if fileManager.fileExists(atPath: fileURL.path()) {
            return fileURL
        }
        return try await downloadTextFile(from: url, savePath: fileURL)
    }
    
    func downloadTextFile(from url: URL, savePath: URL) async throws -> URL {
        let data = try await loadTextFile(from: url)
        try data.write(to: savePath, options: .atomic)
        return savePath
    }
    
    private func loadTextFile(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw TextFileLoaderErrors.badServerResponse
        }
        guard let mimeType = httpResponse.mimeType, mimeType == "text/plain" else {
            throw TextFileLoaderErrors.invalidFileFormat
        }
        return data
    }
}
