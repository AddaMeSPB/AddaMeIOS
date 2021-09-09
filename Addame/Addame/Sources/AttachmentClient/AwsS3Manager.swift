//
//  AwsS3Manager.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import AVFoundation
import FoundationExtension
import KeychainService
import NIO
import S3
import SharedModels
import UIKit

public enum AWSS3Helper {
  public static var bucketWithEndpoint = "https://adda.nyc3.digitaloceanspaces.com/"
  private static let compressionQueue = OperationQueue()

  public static var getCurrentMillis: Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }

  public static func uploadImage(
    _ image: UIImage,
    conversationId: String? = nil,
    userId: String? = nil,
    completion: @escaping (String?) -> Void
  ) {
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      print(#line, "Missing current user from KeychainService")
      return
    }

    let awsS3Service = S3(
      accessKeyId: "",  // EnvironmentKeys.accessKeyId,
      secretAccessKey: "",  // EnvironmentKeys.secretAccessKey,
      region: .useast1,
      endpoint: "https://nyc3.digitaloceanspaces.com"
    )

    let data = image.compressImage(conversationId == nil ? .highest : .medium)
    let imageFormat = data.1
    guard let imageData = data.0 else {
      completion(nil)
      return
    }

    let currentTime = AWSS3Helper.getCurrentMillis
    var imageKey = String(format: "%ld", currentTime)
    if let conversationId = conversationId {
      imageKey = "uploads/images/\(conversationId)/\(imageKey).\(imageFormat)"
    } else if let userId = userId {
      imageKey = "uploads/images/\(userId)/\(imageKey).\(imageFormat)"
    } else {
      imageKey = "uploads/images/\(user.id)_\(imageKey).\(imageFormat) "
    }

    // Put an Object
    let putObjectRequest = S3.PutObjectRequest(
      acl: .publicRead,
      body: imageData,
      bucket: "adda",
      contentLength: Int64(imageData.count),
      key: imageKey
    )

    let futureOutput = awsS3Service.putObject(putObjectRequest)

    futureOutput.whenSuccess { response in
      print(#line, self, response, imageKey)
      let finalURL = bucketWithEndpoint + imageKey
      completion(finalURL)
    }

    futureOutput.whenFailure { error in
      print(#line, self, error)
      completion(nil)
    }
  }
}
