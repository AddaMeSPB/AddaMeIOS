//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HttpRequest
import SharedModels

extension AttachmentClient {
  public static let empty = Self(
    uploadAvatar: { _ in
      Just(Attachment.draff)
        .setFailureType(to: HTTPError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let happyPath = Self(
    uploadAvatar: { _ in
      Just(
        Attachment(
          id: "5fb6736c1432f950f8ea2d33", type: .image,
          userId: "5fabb05d2470c17919b3c0e2",
          // swiftlint:disable:next line_length
          imageUrlString:
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg",
          audioUrlString: nil, videoUrlString: nil,
          fileUrlString: nil,
          createdAt: Date(), updatedAt: Date()
        )
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }
  )
}
