//
//  UserClient.swift
//  
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Foundation
import Combine
import HttpRequest
import SharedModels
import KeychainService

// swiftlint:disable all
var user = User(
  id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218888888", avatarUrl: nil,
  firstName: "First Name :)", lastName: "", email: nil, contactIDs: nil, deviceIDs: nil,
  attachments: [
    Attachment(id: "5fb6736c1432f950f8ea2d33", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fb681d6fb999dc956323a05", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fb6bba4d62847cc58a5218a", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811106589.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fb6bc48d63734254b0eb777", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811270871.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fb7b5e0d54eaebe3d264ace", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605875164101.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fce0931ed6264cb3536a7cb", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338279849.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
    Attachment(id: "5fce094221b4a84f64924bf3", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338304864.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil)
  ],
  createdAt: Date(), updatedAt: Date()
)

extension UserClient {
  public static let happyPath = Self(
    userMeHandler: { _, _   in
     Just(user)
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    update: { _, _  in
      user.firstName = "Swift"
      user.lastName = "Xcode"
      return Just(user)
        .setFailureType(to: HTTPError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let failed = Self(

    userMeHandler: { _, _   in
      Fail(error: HTTPError.authError(404) )
        .eraseToAnyPublisher()
    },
    update: { _, _  in
      Fail(error: HTTPError.authError(404) )
        .eraseToAnyPublisher()
    }
  )

}
