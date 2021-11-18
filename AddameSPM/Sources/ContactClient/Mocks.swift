//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 11.03.2021.
//

import Combine
import CombineContacts
import Contacts
import Foundation
import HTTPRequestKit
import SharedModels

// swiftlint:disable all
private let contacts: [Contact] = [
  .init(
    id: "5faea05b717a5064845accb5", identifier: "BBBA81AD-2D3F-4786-AA1D-7D2E654126B1",
    userId: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217", fullName: "Alif7",
    avatar:
      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg",
    isRegister: true),
  .init(
    id: "5faea05b717a5064845accb5", identifier: "BBBA81AD-2D3F-4786-AA1D-7D2E654126B1",
    userId: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821210", fullName: "Unknow0",
    avatar: "", isRegister: false),
  .init(
    id: "5faea05b717a5064845accb5", identifier: "BBBA81AD-2D3F-4786-AA1D-7D2E654126B1",
    userId: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219", fullName: "Alif9",
    avatar:
      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg",
    isRegister: true),
]

private let users: [User] = [
  .init(
    id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217", createdAt: Date(),
    updatedAt: Date()),
  .init(
    id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219", createdAt: Date(),
    updatedAt: Date()),
  .init(
    id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216", createdAt: Date(),
    updatedAt: Date()),
]
// swiftlint:enable all

extension ContactClient {
  public static let notDetermined = Self(
    authorization: {
      Just(CNAuthorizationStatus.notDetermined)
        .eraseToAnyPublisher()
    },
    buidContacts: {
      Just([])
        .setFailureType(to: ContactError.self)
        .eraseToAnyPublisher()
    },
    getRegisterUsersFromServer: { _ in
      Just([])
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let restricted = Self(
    authorization: {
      Just(CNAuthorizationStatus.restricted)
        .eraseToAnyPublisher()
    },
    buidContacts: {
      Just([])
        .setFailureType(to: ContactError.self)
        .eraseToAnyPublisher()
    },
    getRegisterUsersFromServer: { _ in
      Just([])
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let denied = Self(
    authorization: {
      Just(CNAuthorizationStatus.denied)
        .eraseToAnyPublisher()
    },
    buidContacts: {
      Just([])
        .setFailureType(to: ContactError.self)
        .eraseToAnyPublisher()
    },
    getRegisterUsersFromServer: { _ in
      Just([])
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let authorized = Self(
    authorization: {
      Just(CNAuthorizationStatus.authorized)
        .eraseToAnyPublisher()
    },
    buidContacts: {
      Just(contacts)
        .setFailureType(to: ContactError.self)
        .eraseToAnyPublisher()
    },
    getRegisterUsersFromServer: { _ in
      Just(users)
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )
}
