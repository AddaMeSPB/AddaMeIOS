//
//  User.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 28.09.2020.
//

import Foundation
import KeychainService
import FoundationExtension

// MARK: - User
public struct User: Codable, Equatable, Hashable, Identifiable {

  public static var draff: Self {
    .init(
      id: UUID().uuidString, phoneNumber: "+79212121211",
      avatarUrl: nil, firstName: "1st Draff",
      lastName: "2nd Draff", email: nil,
      contactIDs: nil, deviceIDs: nil, attachments: nil,
      createdAt: Date(), updatedAt: Date()
    )
  }

  public var id, phoneNumber: String
  public var avatarUrl, firstName, lastName, email: String?
  public var contactIDs, deviceIDs: [String]?
  public var attachments: [Attachment]?
  public var createdAt, updatedAt: Date

  public init(
    id: String, phoneNumber: String, avatarUrl: String? = nil,
    firstName: String? = nil, lastName: String? = nil,
    email: String? = nil, contactIDs: [String]? = nil,
    deviceIDs: [String]? = nil, attachments: [Attachment]? = nil,
    createdAt: Date, updatedAt: Date
  ) {
    self.id = id
    self.phoneNumber = phoneNumber
    self.avatarUrl = avatarUrl
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
    self.contactIDs = contactIDs
    self.deviceIDs = deviceIDs
    self.attachments = attachments
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public var fullName: String {
    var fullName = ""
    if let firstN = firstName {
      fullName += "\(firstN) "
    }

    if let lastN = lastName {
      fullName += "\(lastN)"
    }

    if fullName.isEmpty {
      return hideLast4DigitFromPhoneNumber()
    }

    return fullName
  }

  public func hideLast4DigitFromPhoneNumber() -> String {
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      return "SwiftUI preview missing User"
    }

    let lastFourCharacters = String(self.phoneNumber.suffix(4))
    let phoneNumWithLastFourHiddenCharcters = self.phoneNumber.replace(target: lastFourCharacters, withString: "****")

    return user.id == self.id ? self.phoneNumber : phoneNumWithLastFourHiddenCharcters
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: User, rhs: User) -> Bool {
    return
      lhs.id == rhs.id &&
      lhs.avatarUrl == rhs.avatarUrl &&
      lhs.phoneNumber == rhs.phoneNumber &&
      lhs.firstName == rhs.firstName &&
      lhs.lastName == rhs.lastName &&
      lhs.email == rhs.email
  }

}

extension User {

  public var lastAvatarURLString: String? {
    guard let atchmts = self.attachments  else {
      return nil
    }
    print(#line, atchmts)
    return atchmts.filter { $0.type == .image }.last?.imageUrlString
  }

  public var imageURL: URL? {
    guard lastAvatarURLString != nil else {
      return nil
    }

    return URL(string: lastAvatarURLString!)!
  }

}
