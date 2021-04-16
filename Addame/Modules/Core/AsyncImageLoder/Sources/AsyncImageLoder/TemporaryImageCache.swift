//
//  TemporaryImageCache.swift
//  
//
//  Created by Saroar Khandoker on 26.01.2021.
//

import Foundation
import SwiftUI

public protocol ImageCache {
  subscript(_ url: URL) -> UIImage? { get set }
}

public struct TemporaryImageCache: ImageCache {
  
  private let cache = NSCache<NSURL, UIImage>()
  
  public subscript(key: URL) -> UIImage? {
    get { cache.object(forKey: key as NSURL) }
    set {
      newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL)
    }
  }
}
