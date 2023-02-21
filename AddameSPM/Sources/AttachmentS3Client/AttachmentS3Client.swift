//
//  AttachmentClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import AddaSharedModels
import UIKit
import InfoPlist
import KeychainClient
import SotoS3
import Dependencies

public struct AttachmentS3Client {

    public static let bucket = "adda"
    public static var bucketWithEndpoint = "https://adda.nyc3.digitaloceanspaces.com/"

    static public let client = AWSClient(
        credentialProvider: .static(
          accessKeyId: EnvironmentKeys.accessKeyId,
          secretAccessKey: EnvironmentKeys.secretAccessKey
        ),
        httpClientProvider: .createNew
    )

    public static let awsS3 = S3(
        client: client,
        region: .useast1,
        endpoint: "https://nyc3.digitaloceanspaces.com"
    )

    public typealias UploadImageToS3Handler = @Sendable (UIImage, String?, String?) async throws -> String

    public let uploadImageToS3: UploadImageToS3Handler

    public init(uploadImageToS3: @escaping UploadImageToS3Handler) {
        self.uploadImageToS3 = uploadImageToS3
    }
}

extension AttachmentS3Client {
    static public func buildImageKey(
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

    // upload image to DigitalOcen Spaces
    static public func uploadImage(
        image: UIImage,
        conversationId: String? = nil,
        userId: String? = nil
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in

            let data = image.compressImage(conversationId == nil ? .highest : .medium)
            let imageFormat = data.1
            guard let imageData = data.0 else {
                return continuation.resume(throwing: "Data compressImage error")
            }

            let imageKey = buildImageKey(conversationId: conversationId, userId: userId, imageFormat: imageFormat)

            let body = AWSPayload.data(imageData)

            // Put an Object
            let putObjectRequest = S3.PutObjectRequest(
                acl: .publicRead,
                body: body,
                bucket: bucket,
                contentLength: Int64(imageData.count),
                key: imageKey
            )

            let futureOutput = awsS3.putObject(putObjectRequest)

            futureOutput.whenSuccess { response in
                print(#line, self, response, imageKey)
                let finalURL = bucketWithEndpoint + imageKey

                return continuation.resume(returning: finalURL)
            }

            futureOutput.whenFailure { error in
                return continuation.resume(throwing: error.localizedDescription)
            }

        }
    }
}

extension AttachmentS3Client {
    public static var live: AttachmentS3Client =
    .init(
      uploadImageToS3: { image, conversationId, userId in
          return try await AttachmentS3Client.uploadImage(
            image: image,
            conversationId: conversationId,
            userId: userId
          )
      }
    )
}


public enum AttachmentS3ClientKey: TestDependencyKey {
    public static let testValue = AttachmentS3Client.happyPath
}

extension AttachmentS3ClientKey: DependencyKey {
    public static let liveValue: AttachmentS3Client = AttachmentS3Client.live
}

extension DependencyValues {
    public var attachmentS3Client: AttachmentS3Client {
        get { self[AttachmentS3ClientKey.self] }
        set { self[AttachmentS3ClientKey.self] = newValue }
    }
}
