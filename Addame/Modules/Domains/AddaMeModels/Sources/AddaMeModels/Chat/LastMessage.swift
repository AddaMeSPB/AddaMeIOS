//
//  LastMessage.swift
//  
//
//  Created by Saroar Khandoker on 23.02.2021.
//

import Foundation

public struct LastMessage: Codable, Identifiable{
    public var id, senderID: String
    public var phoneNumber: String
    public var firstName, lastName: String?
    public var avatar, messageBody: String
    public var totalUnreadMessages: Int
    public var timestamp: Int

    public enum CodingKeys: String, CodingKey {
        case senderID = "sender_id"
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case messageBody = "message_body"
        case totalUnreadMessages = "total_unread_messages"
        case id, avatar, timestamp
    }
}

extension LastMessage: Hashable  {
  public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
      hasher.combine(phoneNumber)
  }
}
