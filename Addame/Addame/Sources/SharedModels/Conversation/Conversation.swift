//
//  Conversation.swift
//
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Foundation
import FoundationExtension
import KeychainService

public struct AddUser: Codable {
  public let conversationsId: String
  public let usersId: String

  public init(conversationsId: String, usersId: String) {
    self.conversationsId = conversationsId
    self.usersId = usersId
  }
}

public struct CreateConversation: Codable, Equatable {
  public init(title: String, type: ConversationType, opponentPhoneNumber: String) {
    self.title = title
    self.type = type
    self.opponentPhoneNumber = opponentPhoneNumber
  }

  public let title: String
  public let type: ConversationType
  public let opponentPhoneNumber: String
}

public enum ConversationType: String, Codable, Equatable {
  case oneToOne, group
}

public struct Conversation: Codable, Hashable, Identifiable {
  public let id, title: String
  public var type: ConversationType
  public let members: [User]?
  public let admins: [User]?
  public var lastMessage: ChatMessageResponse.Item?

  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: String, title: String, type: ConversationType,
    members: [User]? = nil, admins: [User]? = nil,
    lastMessage: ChatMessageResponse.Item? = nil,
    createdAt: Date, updatedAt: Date
  ) {
    self.id = id
    self.title = title
    self.type = type
    self.members = members
    self.admins = admins
    self.lastMessage = lastMessage
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
    lhs.id == rhs.id
  }
}

public struct ConversationResponse: Codable, Equatable {
  public let items: [Item]
  public let metadata: Metadata

  public init(items: [Item], metadata: Metadata) {
    self.items = items
    self.metadata = metadata
  }

  public struct Item: Codable, Hashable, Identifiable, Comparable, Equatable {
    init(
      id: String, title: String, type: ConversationType,
      members: [User], admins: [User],
      lastMessage: ChatMessageResponse.Item?,
      createdAt: Date, updatedAt: Date
    ) {
      self.id = id
      self.title = title
      self.type = type
      self.members = members
      self.admins = admins
      self.lastMessage = lastMessage
      self.createdAt = createdAt
      self.updatedAt = updatedAt
    }

    public static var defint: Self {
      .init(
        id: ObjectIdGenerator.shared.generate(),
        title: "defualt", type: .group, members: [],
        admins: [], lastMessage: nil,
        createdAt: Date(), updatedAt: Date()
      )
    }

    public init(_ conversation: Conversation) {
      id = conversation.id
      title = conversation.title
      type = conversation.type
      members = conversation.members
      admins = conversation.admins

      lastMessage = conversation.lastMessage
      createdAt = conversation.createdAt
      updatedAt = conversation.updatedAt
    }

    public var wSconversation: Conversation {
      .init(
        id: id, title: title, type: type,
        members: nil, admins: nil, lastMessage: nil,
        createdAt: Date(), updatedAt: Date()
      )
    }

    public let id, title: String
    public var type: ConversationType
    public let members: [User]?
    public let admins: [User]?
    public var lastMessage: ChatMessageResponse.Item?

    public let createdAt, updatedAt: Date

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: Item, rhs: Item) -> Bool {
      lhs.id == rhs.id
    }

    public static func < (lhs: Item, rhs: Item) -> Bool {
      guard let lhsLstMsg = lhs.lastMessage, let rhsLstMsg = rhs.lastMessage,
        let lhsDate = lhsLstMsg.updatedAt, let rhsDate = rhsLstMsg.updatedAt
      else { return false }
      return lhsDate > rhsDate
    }
  }
}

extension ConversationResponse {
  public struct UserAdd: Codable, Hashable, Identifiable, Comparable, Equatable {
    public let id, title: String
    public let type: ConversationType
    public let createdAt, updatedAt: Date
    public let deletedAt: Date?

    public static var diff: Self {
      .init(
        id: "", title: "", type: .group,
        createdAt: Date(), updatedAt: Date()
      )
    }

    public init(
      id: String, title: String, type: ConversationType,
      createdAt: Date, updatedAt: Date, deletedAt: Date? = nil
    ) {
      self.id = id
      self.title = title
      self.type = type
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.deletedAt = deletedAt
    }

    public static func < (lhs: ConversationResponse.UserAdd, rhs: ConversationResponse.UserAdd)
      -> Bool
    {
      return lhs.id == rhs.id
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
    }
  }
}

// public extension ConversationResponse.Item {
//
//    func canJoinConversation() -> Bool {
//        guard let user: User = KeychainService.loadCodable(for: .user) else {
//            return false
//        }
//
//        return self.admins!.contains(where: { $0.id == user.id }) ||
//            self.members!.contains(where: { $0.id == user.id })
//
//    }
//
// }
