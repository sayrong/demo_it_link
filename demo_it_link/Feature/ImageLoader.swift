//
//  ImageLoader.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import UIKit
import ImageIO
import CryptoKit

enum ImageType {
    case thumbnail
    case original
}

actor ImageLoader {
    
    static let shared = ImageLoader()
    
    private let imageThumbnailCache = NSCache<NSURL, UIImage>()
    private let imageCache = NSCache<NSURL, UIImage>()
    
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    private struct LoadKey: Hashable {
        let url: URL
        let type: ImageType
    }
    
    private var images: [LoadKey: LoaderStatus] = [:]
    
    init() {
        imageThumbnailCache.countLimit = 100
        imageCache.countLimit = 100
    }
    
    func loadImage(from url: URL, type: ImageType) async throws -> UIImage {
        try Task.checkCancellation()
        
        let key = LoadKey(url: url, type: type)
        if let status = images[key] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        if let memCached = loadFromCache(url: url, type: type) {
            images[key] = .fetched(memCached)
            return memCached
        }
        
        if let diskCached = try loadImageFromDisk(url: url, type: type) {
            cache(for: type).setObject(diskCached, forKey: url as NSURL)
            images[key] = .fetched(diskCached)
            return diskCached
        }
        
        let task: Task<UIImage, Error> = Task {
            try await processImage(url, type)
        }
        
        images[key] = .inProgress(task)
        defer { images.removeValue(forKey: key) }
        
        let image = try await task.value
        images[key] = .fetched(image)
        
        return image
    }
    
    private func processImage(_ url: URL, _ type: ImageType) async throws -> UIImage {
        try Task.checkCancellation()
        // Лезем в сеть
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        // Создание thumbnail
        let thumbnail = try await createThumbnailAsync(data: data)
        // В кэш отправляет только то с чем взаимодействовали
        if type == .original {
            imageCache.setObject(image, forKey: url as NSURL)
        } else {
            imageThumbnailCache.setObject(thumbnail, forKey: url as NSURL)
        }
        // Сохраняет на диск оба типа без ожидания
        Task.detached {
            do {
                try await self.saveImages(data: data, thumbnail: thumbnail, url: url)
            } catch {
                print(error.localizedDescription)
            }
        }
        return type == .original ? image : thumbnail
    }
    
    private func createThumbnailAsync(data: Data) async throws -> UIImage {
        try await Task.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            guard let thumbnail = await self.createThumbnail(from: data) else {
                throw URLError(.cannotCreateFile)
            }
            return thumbnail
        }.value
    }
    
    private func saveImages(data: Data, thumbnail: UIImage, url: URL) async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.saveImageDataToDisk(data, url: url, for: .original)
            }
            
            group.addTask {
                if let jpgData = thumbnail.jpegData(compressionQuality: 0.8) {
                    try await self.saveImageDataToDisk(jpgData, url: url, for: .thumbnail)
                }
            }
        }
    }
    
    private func cache(for type: ImageType) -> NSCache<NSURL, UIImage> {
        type == .original ? imageCache : imageThumbnailCache
    }

    private func createThumbnail(from imageData: Data, maxPixelSize: Int = 350) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func loadFromCache(url: URL, type: ImageType) -> UIImage? {
        let cache = type == .original ? imageCache : imageThumbnailCache
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        return nil
    }
    
    private func loadImageFromDisk(url: URL, type: ImageType) throws -> UIImage? {
        let fileURL = try localFileUrl(from: url, for: type)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func saveImageDataToDisk(_ imageData: Data, url: URL, for type: ImageType) throws {
        let fileURL = try localFileUrl(from: url, for: type)
        try imageData.write(to: fileURL)
    }
    
    private func localFileUrl(from remoteUrl: URL, for type: ImageType) throws -> URL {
        let cacheDir = try cacheDirectory(for: type)
        let fileName = hashedFilename(for: remoteUrl)
        let fileURL = cacheDir.appendingPathComponent(fileName)
        return fileURL
    }
    
    private func cacheDirectory(for type: ImageType) throws -> URL {
        let dirName = type == .original ? "images" : "thumbnails"
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let newDir = cacheDir.appendingPathComponent(dirName)
        guard !FileManager.default.fileExists(atPath: newDir.path()) else {
            return newDir
        }
        try FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: true)
        return newDir
    }
    
    private func hashedFilename(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
