//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import AttachmentClient
import Combine
import Foundation
import HTTPRequestKit
import SotoS3
import InfoPlist
import AddaSharedModels
import KeychainService
import UIKit

extension AttachmentClient {
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
                    return continuation.resume(throwing: HTTPRequest.HRError.custom("Data compressImage error", .none))
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
                    return continuation.resume(throwing: HTTPRequest.HRError.networkError(error))
                }

            }

    }
}

extension AttachmentClient {
    public static var live: AttachmentClient =
    .init(
      uploadImageToS3: { image, conversationId, userId in
          return try await AttachmentClient.uploadImage(
            image: image,
            conversationId: conversationId,
            userId: userId
          )
      },
      updateUserImageURL: { attachment in
          return try await AttachmentClient.apiClient.decodedResponse(
            for: .authEngine(
                .users(
                    .user(
                        id: attachment.userId!.hexString,
                        route: .attachments(.create(input: attachment))
                    )
                )
            ),
            as: AttachmentInOutPut.self,
            decoder: .iso8601
          ).value
      }
    )

}
