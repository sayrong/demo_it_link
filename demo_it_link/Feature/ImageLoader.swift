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

class ImageLoader {
    
    static let shared = ImageLoader()
    
    private let imageThumbnailCache = NSCache<NSURL, UIImage>()
    private let imageCache = NSCache<NSURL, UIImage>()
    
    init() {
        imageThumbnailCache.countLimit = 100
        imageCache.countLimit = 100
    }
    
    func loadImage(from url: URL, type: ImageType) async throws -> UIImage {
        if let memCached = loadFromCache(url: url, type: type) {
            return memCached
        }
        if let diskCached = try loadImageFromDisk(url: url, type: type) {
            cache(for: type).setObject(diskCached, forKey: url as NSURL)
            return diskCached
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data),
              let thumbnail = createThumbnail(from: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        // В кэш отправляет только то с чем взаимодействовали
        if type == .original {
            imageCache.setObject(image, forKey: url as NSURL)
        } else {
            imageThumbnailCache.setObject(thumbnail, forKey: url as NSURL)
        }
        // Сохраняет на диск оба типа
        try saveImageDataToDisk(data, url: url, for: .original)
        if let jpgData = thumbnail.jpegData(compressionQuality: 1) {
            try saveImageDataToDisk(jpgData, url: url, for: .thumbnail)
        }
        return type == .original ? image : thumbnail
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
    
    func saveImageDataToDisk(_ imageData: Data, url: URL, for type: ImageType) throws {
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
