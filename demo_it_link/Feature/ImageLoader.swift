//
//  ImageLoader.swift
//  demo_it_link
//
//  Created by DmitrySK on 28.05.2025.
//

import UIKit
import ImageIO
import CryptoKit

class ImageLoader {
    
    static let shared = ImageLoader()
    
    let thumbnailsDirName = "thumbnails"
    let originalImagesDirName = "images"
    
    enum ImageType {
        case thumbnail
        case original
    }
    private let imageThumbnailCache = NSCache<NSURL, UIImage>()
    private let imageCache = NSCache<NSURL, UIImage>()
    
    init() {
        imageThumbnailCache.countLimit = 100
        imageCache.countLimit = 100
    }
    
    func loadThumbnail(from url: URL) async throws -> UIImage {
        if let cached = imageThumbnailCache.object(forKey: url as NSURL) {
            return cached
        }
        if let diskThumb = loadImageFromDisk(url: url, type: .thumbnail) {
            imageThumbnailCache.setObject(diskThumb, forKey: url as NSURL)
            return diskThumb
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = createThumbnail(from: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        imageCache.setObject(image, forKey: url as NSURL)
        return image
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
    
    private func loadImageFromDisk(url: URL, type: ImageType) -> UIImage? {
        let cacheDir = cacheDirectory(for: type)
        let fileName = hashedFilename(for: url)
        let fileURL = cacheDir.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func cacheDirectory(for type: ImageType) -> URL {
        let dirName = type == .original ? "images" : "thumbnails"
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let newDir = cacheDir.appendingPathComponent(dirName)
        guard !FileManager.default.fileExists(atPath: newDir.path()) else {
            return newDir
        }
        try? FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: true)
        return newDir
    }
    
    private func hashedFilename(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func saveImageDataToDisk(_ imageData: Data, url: URL, for type: ImageType) {
        
    }

//    func saveImageToDisk(_ image: UIImage, url: URL) {
//        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
//        try? data.write(to: imageFileURL(for: url))
//    }

    

    
}
