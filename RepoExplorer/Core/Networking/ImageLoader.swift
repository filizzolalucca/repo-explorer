//
//  ImageLoader.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import UIKit

// Downloads images and keeps them in memory, so the avatar
// doesn't download again every time its cell is reused.
final class ImageLoader {
    static let shared = ImageLoader()

    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func image(from url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        guard let (data, _) = try? await session.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
