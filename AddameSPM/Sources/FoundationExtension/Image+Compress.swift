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
  import AppKit
  import Cocoa

  typealias UIImage = NSImage
  extension NSImage {
    var cgImage: CGImage? {
      var proposedRect = CGRect(origin: .zero, size: size)

      return cgImage(
        forProposedRect: &proposedRect,
        context: nil,
        hints: nil)
    }

    convenience init?(named name: String) {
      self.init(named: Name(name))
    }
  }

#endif

extension UIImage {
  public enum JPEGQuality: CGFloat {
    case lowest = 0
    case low = 0.25
    case medium = 0.5
    case high = 0.75
    case highest = 1
  }

  private var isHeicSupported: Bool {
    // swiftlint:disable force_cast
      (CGImageDestinationCopyTypeIdentifiers() as! [String]).contains("public.heic")
  }

  public func compressImage(_ compressionQuality: JPEGQuality? = .medium) -> (Data?, String) {

    if isHeicSupported {
      do {
        let data = try heicData(compressionQuality: compressionQuality!)
        return (data, "heic")
      } catch {
        print("Error creating HEIC data: \(error.localizedDescription)")
      }
    } else {
      #if os(iOS)
        guard let data = jpegData(compressionQuality: compressionQuality!.rawValue) else {
          return (nil, "")
        }

        return (data, "jpeg")

      #elseif os(OSX)
        fatalError("Value of type 'NSImage' has no member 'jpegData'")
      #endif
    }

    return (nil, "")
  }

}

extension UIImage {
  public enum HEICError: Error {
    case heicNotSupported
    case cgImageMissing
    case couldNotFinalize
  }

  public func heicData(compressionQuality: JPEGQuality) throws -> Data {
    let data = NSMutableData()
    guard
      let imageDestination =
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

extension UIImage {
    public func heicData2(compressionQuality: JPEGQuality) -> Data? {
        let destinationData = NSMutableData()

        guard
            let cgImage = self.cgImage,
            let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, 1, nil)
            else { return nil }

        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)

        return destinationData as Data
    }
}
