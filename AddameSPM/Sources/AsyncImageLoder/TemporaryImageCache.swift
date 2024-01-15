//
//  TemporaryImageCache.swift
//
//
//  Created by Saroar Khandoker on 26.01.2021.
//

import Foundation
import SwiftUI

public protocol ImageCache {
  subscript(_: URL) -> UIImage? { get set }
}

public struct TemporaryImageCache: ImageCache {
  private let cache = NSCache<NSURL, UIImage>()

  public subscript(key: URL) -> UIImage? {
    get { cache.object(forKey: key as NSURL) }
    set {
      newValue == nil
        ? cache.removeObject(forKey: key as NSURL)
        : cache.setObject(newValue!, forKey: key as NSURL)
    }
  }
}


//public struct ImageCacheClient {
//
//    public var url: (_: URL) -> UIImage?
//    private let cache = NSCache<NSURL, UIImage>()
//
//    public init(url: @escaping (URL) -> UIImage?) {
//        self.url = url
//    }
//
//    public subscript(key: URL) -> UIImage? {
//      get { cache.object(forKey: key as NSURL) }
//      set {
//        newValue == nil
//          ? cache.removeObject(forKey: key as NSURL)
//          : cache.setObject(newValue!, forKey: key as NSURL)
//      }
//    }
//}
//
//extension ImageCacheClient: DependencyKey {
//    public static var liveValue: Self = .init { url in
//        return UIImage(url: url)
//    }
//}

//public struct ImageCacheClient {
//    public var imageForUrl: (URL) -> UIImage?
//    public var images: (URL) -> Void
//
//    public init(
//        imageForUrl: @escaping (URL) -> UIImage?,
//        images: @escaping (URL) -> Void
//    ) {
//        self.imageForUrl = imageForUrl
//        self.images = images
//    }
//}
//
//extension ImageCacheClient: DependencyKey {
//    public static var liveValue: ImageCacheClient = {
//        let cache = NSCache<NSURL, UIImage>()
//
//        return Self(
//            imageForUrl: { url in
//                cache.object(forKey: url as NSURL)
//            },
//            images: { key in
//                if images[key]
//                        newValue == nil
//                          ? cache.removeObject(forKey: key as NSURL)
//                          : cache.setObject(newValue!, forKey: key as NSURL)
//            }
//        )
//    }()
//}


//extension DependencyValues {
//  public var imageCacheClient: ImageCacheClient {
//    get { self[ImageCacheClient.self] }
//    set { self[ImageCacheClient.self] = newValue }
//  }
//}

import os

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }

        do {
            self.init(data: try Data(contentsOf: url))
        } catch {
            logger.error("\(#function) \(#line) \(error.localizedDescription)")
            return nil
        }
    }
}

public let logger = Logger(subsystem: "com.addame.AddaMeIOS", category: "uiimage")

