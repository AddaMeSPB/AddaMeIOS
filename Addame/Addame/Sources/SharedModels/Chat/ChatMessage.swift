//
//  ChatMessage.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 28.09.2020.
//

import Foundation

public struct ChatMessage: Codable, Identifiable {
  
  public init(id: String? = nil, conversationId: String, messageBody: String, sender: User, recipient: User? = nil, messageType: MessageType, isRead: Bool, isDelivered: Bool, createdAt: Date? = nil, updatedAt: Date? = nil) {
    self.id = id
    self.conversationId = conversationId
    self.messageBody = messageBody
    self.sender = sender
    self.recipient = recipient
    self.messageType = messageType
    self.isRead = isRead
    self.isDelivered = isDelivered
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  public var id: String?
  public var conversationId, messageBody: String
  public var sender: User
  public var recipient: User?
  public var messageType: MessageType
  public var isRead, isDelivered: Bool
  
  public var createdAt, updatedAt: Date?
  
  public var messageResponse: ChatMessageResponse.Item {
    .init(id: id, conversationId: conversationId, messageBody: messageBody, sender: sender, recipient: recipient, messageType: messageType, isRead: isRead, isDelivered: isDelivered, createdAt: createdAt, updatedAt: updatedAt)
  }
  
  public init(_ chatMessage: ChatMessageResponse.Item) {
    self.id = chatMessage.id
    self.conversationId = chatMessage.conversationId
    self.messageBody = chatMessage.messageBody
    self.sender = chatMessage.sender
    self.recipient = chatMessage.recipient
    self.messageType = chatMessage.messageType
    self.isRead = chatMessage.isRead
    self.isDelivered = chatMessage.isDelivered
    self.createdAt = chatMessage.createdAt
    self.updatedAt = chatMessage.updatedAt
  }
}

extension ChatMessage: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(messageBody)
  }
}

public struct ChatMessageResponse: Codable, Equatable {

  public let items: [Item]
  public let metadata: Metadata
  
  public init(items: [ChatMessageResponse.Item], metadata: Metadata) {
    self.items = items
    self.metadata = metadata
  }
  
  public struct Item: Codable, Identifiable, Hashable, Comparable, Equatable {
    
    public var id: String?
    public var conversationId, messageBody: String
    public var sender: User
    public var recipient: User?
    public var messageType: MessageType
    public var isRead, isDelivered: Bool
    public var createdAt, updatedAt: Date?
    
    public init(id: String? = nil, conversationId: String, messageBody: String, sender: User, recipient: User? = nil, messageType: MessageType, isRead: Bool, isDelivered: Bool, createdAt: Date? = nil, updatedAt: Date? = nil) {
      self.id = id
      self.conversationId = conversationId
      self.messageBody = messageBody
      self.sender = sender
      self.recipient = recipient
      self.messageType = messageType
      self.isRead = isRead
      self.isDelivered = isDelivered
      self.createdAt = createdAt
      self.updatedAt = updatedAt
    }
    
    public init(_ chatMessage: ChatMessage) {
      self.id = chatMessage.id
      self.conversationId = chatMessage.conversationId
      self.messageBody = chatMessage.messageBody
      self.sender = chatMessage.sender
      self.recipient = chatMessage.recipient
      self.messageType = chatMessage.messageType
      self.isRead = chatMessage.isRead
      self.isDelivered = chatMessage.isDelivered
      self.createdAt = chatMessage.createdAt
      self.updatedAt = chatMessage.updatedAt
    }
    
    public var wSchatMessage: ChatMessage {
      .init(id: id, conversationId: conversationId, messageBody: messageBody, sender: sender, recipient: recipient, messageType: messageType, isRead: isRead, isDelivered: isDelivered, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    public static func == (lhs: Item, rhs: Item) -> Bool {
      lhs.id == rhs.id
    }
    
    public static func < (lhs: Item, rhs: Item) -> Bool {
      guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else { return false }
      return lhsDate > rhsDate
    }
    
  }
}

public enum MessageType: String, Codable, Equatable {
  case text, image, audio, video
}

