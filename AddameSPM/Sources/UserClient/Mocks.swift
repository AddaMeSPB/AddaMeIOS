//
//  UserClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import KeychainService
import AddaSharedModels

extension UserClient {
  public static let happyPath = Self(
    userMeHandler: { _ in UserOutput.withAttachments },
    update: { _ in
        UserOutput.withAttachments.firstName = "Swift"
        UserOutput.withAttachments.lastName = "Xcode"
      return UserOutput.withAttachments
    },
    delete: { _ in true }
  )

  public static let failed = Self(
    userMeHandler: { _ in UserOutput.withAttachments },
    update: { _ in UserOutput.withAttachments },
    delete: { _ in false }
  )
}
