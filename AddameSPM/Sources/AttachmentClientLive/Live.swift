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
import SharedModels
import KeychainService
import UIKit

func token() -> AnyPublisher<String, HTTPRequest.HRError> {
  guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
    print(#line, "not Authorized Token are missing")
    return Fail(error: HTTPRequest.HRError.missingTokenFromIOS)
      .eraseToAnyPublisher()
  }

  return Just(token.accessToken)
    .setFailureType(to: HTTPRequest.HRError.self)
    .eraseToAnyPublisher()
}

public struct AttachmentAPI {
  public static let build = Self()

  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/attachments") }

  private static let bucket = "adda"
  private var bucketWithEndpoint = "https://adda.nyc3.digitaloceanspaces.com/"

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

  fileprivate func handleDataType<Input: Encodable>(
    input: Input? = nil,
    params: [String: Any] = [:],
    queryItems: [URLQueryItem] = []
  ) -> HTTPRequest.DataType {
    if !params.isEmpty {
      return .query(with: params)
    } else if !queryItems.isEmpty {
      return .query(with: queryItems)
    } else {
      return .encodable(input: input, encoder: .init())
    }
  }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input? = nil,
    path: String,
    method: HTTPRequest.Method,
    params: [String: Any] = [:],
    queryItems: [URLQueryItem] = []
  ) -> AnyPublisher<Output, HTTPRequest.HRError> {
    return token().flatMap { token -> AnyPublisher<Output, HTTPRequest.HRError> in

      let builder: HTTPRequest = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: handleDataType(input: input, params: params, queryItems: queryItems)
      )

      return builder.send(scheduler: RunLoop.main)
        .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Output, HTTPRequest.HRError> in
          Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Output, HTTPRequest.HRError> in
      Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  func updateUserImage(attachment: Attachment, path: String) -> AnyPublisher<Attachment, HTTPRequest.HRError> {

    return tokenHandle(input: attachment, path: path, method: .post)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Attachment, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  func buildImageKey(
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

extension AttachmentAPI {
  // upload image to DigitalOcen Spaces
  // swiftlint:disable function_body_length superfluous_disable_command
  func uploadImage(
    image: UIImage,
    conversationId: String? = nil,
    userId: String? = nil
  ) -> AnyPublisher<String, HTTPRequest.HRError> {

    Combine.Future<String, HTTPRequest.HRError> { promise in

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

      let futureOutput = AttachmentAPI.awsS3.putObject(putObjectRequest)

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
      .eraseToAnyPublisher()
  }
}

extension AttachmentClient {
  public static func live(api: AttachmentAPI) -> Self {
    .init(
      uploadImageToS3: api.uploadImage(image:conversationId:userId:),
      updateUserImageURL: api.updateUserImage(attachment:path:)
    )
  }
}
