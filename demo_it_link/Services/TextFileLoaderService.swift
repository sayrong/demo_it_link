//
//  TextFileLoaderService.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import Foundation

enum TextFileLoaderErrors: Error {
    case invalidSourceURL
    case badServerResponse
    case invalidFileFormat
}

class TextFileLoaderService {
    
    let session: URLSession
    let fileManager: FileManager
    
    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }
    
    func downloadTextFile(from source: String) async throws -> URL {
        guard let url = URL(string: source) else {
            throw TextFileLoaderErrors.invalidSourceURL
        }
        let data = try await loadTextFile(from: url)
        let fileName = url.lastPathComponent
        let newLocation = try await saveTextFile(data: data, fileName: fileName)
        return newLocation
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
    
    private func saveTextFile(data: Data, fileName: String) async throws -> URL {
        let cacheURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = cacheURL.appending(path: fileName, directoryHint: .notDirectory)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}
