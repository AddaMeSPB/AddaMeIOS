//
//  EnvironmentValues+ImageCache.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 31.08.2020.
//

import SwiftUI

public struct ImageCacheKey: EnvironmentKey {
  public static let defaultValue: ImageCache = TemporaryImageCache()
}

public extension EnvironmentValues {
  var imageCache: ImageCache {
    get { self[ImageCacheKey.self] }
    set { self[ImageCacheKey.self] = newValue }
  }
}
