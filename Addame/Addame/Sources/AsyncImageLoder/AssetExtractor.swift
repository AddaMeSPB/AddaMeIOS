//
//  AssetExtractor.swift
//  
//
//  Created by Saroar Khandoker on 26.01.2021.
//

import Foundation
#if os(macOS)

#else
import UIKit
#endif

public class AssetExtractor {
  
  public static func createLocalUrl(forImageNamed name: String) -> URL? {
    
    let fileManager = FileManager.default
    let cacheDirectory = fileManager.urls(
      for: .cachesDirectory, in: .userDomainMask
    )[0]

    let url = cacheDirectory.appendingPathComponent("\(name).png")
    
    guard fileManager.fileExists(atPath: url.path) else {
      guard
        let image = UIImage(named: name),
        let data = image.pngData()
      else {
        print(#line, self, "cant find image by name: \(name)")
        return nil
      }
      
      fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
      return url
    }
    
    return url
  }
  
}
