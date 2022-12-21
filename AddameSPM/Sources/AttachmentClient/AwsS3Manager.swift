//
//  AwsS3Manager.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import AVFoundation
import FoundationExtension
import KeychainClient
import NIO
import SotoS3
import AddaSharedModels
import UIKit
import Combine
import HTTPRequestKit
import InfoPlist

public enum AWSS3Helper {
  private static let bucket = "adda"
  public static var bucketWithEndpoint = "https://adda.nyc3.digitaloceanspaces.com/"
  private static let compressionQueue = OperationQueue()

  public static var getCurrentMillis: Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }

  private static let client = AWSClient(
      credentialProvider: .static(
        accessKeyId: EnvironmentKeys.accessKeyId,
        secretAccessKey: EnvironmentKeys.secretAccessKey
      ),
      httpClientProvider: .createNew
  )

  private static let awsS3 = S3(
    client: client,
    region: .useast1,
    endpoint: "https://nyc3.digitaloceanspaces.com"
  )

  // swiftlint:disable function_body_length superfluous_disable_command
  public static func uploadImage(
    _ image: UIImage,
    conversationId: String? = nil,
    userId: String? = nil
  ) -> Combine.Future<String, HTTPRequest.HRError> {

    return Combine.Future<String, HTTPRequest.HRError> { promise in
      let data = image.compressImage(conversationId == nil ? .highest : .medium)

      let imageFormat = data.1
      guard let imageData = data.0 else {
        promise(.failure(HTTPRequest.HRError.custom("Data compressImage error", .none)))
        return
      }

      let imageKey = buildImageKey(conversationId: conversationId, userId: userId, imageFormat: imageFormat)

      let body = AWSPayload.data(imageData)

      // Put an Object
      let putObjectRequest = S3.PutObjectRequest(
        acl: .publicRead,
        body: body,
        bucket: "adda",
        contentLength: Int64(imageData.count),
        key: imageKey
      )

      let futureOutput = awsS3.putObject(putObjectRequest)

      futureOutput.whenSuccess { response in
        print(#line, self, response, imageKey)
        let finalURL = bucketWithEndpoint + imageKey
        promise(.success(finalURL))
      }

      futureOutput.whenFailure { error in
        print(#line, self, error)
        promise(.failure(HTTPRequest.HRError.networkError(error)))
      }
    }
  }

  private static func buildImageKey(
    conversationId: String? = nil,
    userId: String? = nil,
    imageFormat: String
  ) -> String {
    let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
    var imageKey = String(format: "%ld", currentTime)
    if let conversationId = conversationId {
      imageKey = "uploads/images/\(conversationId)/\(imageKey).\(imageFormat)"
    } else if let userId = userId {
      imageKey = "uploads/images/\(userId)/\(imageKey).\(imageFormat)"
    }

    return imageKey
  }

}
