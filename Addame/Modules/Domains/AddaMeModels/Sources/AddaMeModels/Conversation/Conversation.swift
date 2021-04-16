//
//  Conversation.swift
//  
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Foundation
import KeychainService
import FoundationExtension

public struct AddUser: Codable {
  
  public let conversationsId: String
  public let usersId: String
  
  public init(conversationsId: String, usersId: String) {
    self.conversationsId = conversationsId
    self.usersId = usersId
  }

}

public struct CreateConversation: Codable {
  public let title: String
  public let type: ConversationType
  public let opponentPhoneNumber: String
}

public enum ConversationType: String, Codable {
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
  
  public init(id: String, title: String, type: ConversationType, members: [User]? = nil , admins: [User]? = nil , lastMessage: ChatMessageResponse.Item? = nil, createdAt: Date, updatedAt: Date) {
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

public struct ConversationResponse: Codable {

  public let items: [Item]
  public let metadata: Metadata

  public init(items: [Item], metadata: Metadata) {
    self.items = items
    self.metadata = metadata
  }
  
  public struct Item: Codable, Hashable, Identifiable, Comparable {
     init(id: String, title: String, type: ConversationType, members: [User], admins: [User], lastMessage: ChatMessageResponse.Item?, createdAt: Date, updatedAt: Date) {
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
      .init(id: ObjectIdGenerator.shared.generate(), title: "defualt", type: .group, members: [], admins: [], lastMessage: nil, createdAt: Date(), updatedAt: Date())
    }

    public init(_ conversation: Conversation) {
      self.id = conversation.id
      self.title = conversation.title
      self.type = conversation.type
      self.members = conversation.members
      self.admins = conversation.admins

      self.lastMessage = conversation.lastMessage
      self.createdAt = conversation.createdAt
      self.updatedAt = conversation.updatedAt
    }

    public var wSconversation: Conversation {
      .init(id: id, title: title, type: type, members: nil, admins: nil, lastMessage: nil, createdAt: Date(), updatedAt: Date())
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
      guard let lhsLstMsg = lhs.lastMessage,   let rhsLstMsg = rhs.lastMessage,
            let lhsDate = lhsLstMsg.updatedAt, let rhsDate = rhsLstMsg.updatedAt
      else { return false }
      return lhsDate > rhsDate
    }

  }

}

//public extension ConversationResponse.Item {
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
//}
