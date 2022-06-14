//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import SharedModels

// swiftlint:disable line_length superfluous_disable_command
extension AttachmentClient {
  public static let empty = Self(
    uploadImageToS3: { _, _, _ in
      Just("")
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    },
    updateUserImageURL: { _, _ in
      Just(
        Attachment.draff
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    }
  )

  public static let happyPath = Self(

    uploadImageToS3: { _, _, _ in
      Just("https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg")
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    },
    updateUserImageURL: { _, _ in
      Just(
        Attachment(
          id: "5fb6736c1432f950f8ea2d33", type: .image,
          userId: "5fabb05d2470c17919b3c0e2",
          imageUrlString:
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg",
          audioUrlString: nil, videoUrlString: nil,
          fileUrlString: nil,
          createdAt: Date(), updatedAt: Date()
        )
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    }
  )
}
