//
//  Image+Compress.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 19.11.2020.
//

import AVFoundation
import SwiftUI

#if os(iOS)
  import UIKit
#elseif os(OSX)
  import Cocoa
  import AppKit
 
  typealias UIImage = NSImage
  extension NSImage {
      var cgImage: CGImage? {
          var proposedRect = CGRect(origin: .zero, size: size)

          return cgImage(forProposedRect: &proposedRect,
                         context: nil,
                         hints: nil)
      }

      convenience init?(named name: String) {
          self.init(named: Name(name))
      }
  }

#endif



public extension UIImage {
  enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
  }
  
  func compressImage(_ compressionQuality: JPEGQuality? = .medium) -> (Data?, String) {
    var unsuported = false
    var imageData = Data()
    var imageFormat = "jpeg"
    
    do {
      let data = try self.heicData(compressionQuality: compressionQuality!)
      imageData =  data
      imageFormat = "heic"
    } catch {
      print("Error creating HEIC data: \(error.localizedDescription)")
      unsuported = true
    }
    
    if unsuported == true {
      
      
      #if os(iOS)
        guard let data = self.jpegData(compressionQuality: compressionQuality!.rawValue) else {
          return (nil, imageFormat)
        }
        
        imageData = data
      
      #elseif os(OSX)
        fatalError("Value of type 'NSImage' has no member 'jpegData'")
      #endif
      
    }
    
    return (imageData, imageFormat)
    
  }
  
}

public extension UIImage {
  enum HEICError: Error {
    case heicNotSupported
    case cgImageMissing
    case couldNotFinalize
  }
  
  func heicData(compressionQuality: JPEGQuality) throws -> Data {
    let data = NSMutableData()
    guard let imageDestination =
            CGImageDestinationCreateWithData(
              data, AVFileType.heic as CFString, 1, nil
            )
    else {
      throw HEICError.heicNotSupported
    }
    
    guard let cgImage = self.cgImage else {
      throw HEICError.cgImageMissing
    }
    
    let options: NSDictionary = [
      kCGImageDestinationLossyCompressionQuality: compressionQuality.rawValue
    ]
    
    CGImageDestinationAddImage(imageDestination, cgImage, options)
    guard CGImageDestinationFinalize(imageDestination) else {
      throw HEICError.couldNotFinalize
    }
    
    return data as Data
  }
}
