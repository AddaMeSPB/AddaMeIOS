//
//  Contact.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 02.09.2020.
//

import Foundation
import CoreData

public struct Contact: Codable, Identifiable {

    public var id: String?
    public var identifier: String
    public var phoneNumber: String
    public var fullName: String?
    public var avatar: String?
    public var isRegister: Bool?
    public var userId: String?

    public var response: Res {
        .init(self)
    }

    public init(id: String? = nil,
         identifier: String,
         userId: String? = nil,
         phoneNumber: String,
         fullName: String? = nil,
         avatar: String? = nil,
         isRegister: Bool = false
    ) {
        self.id = id
        self.identifier = identifier
        self.userId = userId
        self.phoneNumber = phoneNumber
        self.fullName = fullName
        self.avatar = avatar
        self.isRegister = isRegister
    }

//    public init(_ contactEntity: ContactEntity) {
//      self.id = contactEntity.id
//      self.userId = contactEntity.userId
//      self.identifier = contactEntity.identifier
//      self.fullName = contactEntity.fullName
//      self.avatar = contactEntity.avatar
//      self.phoneNumber = contactEntity.phoneNumber
//      self.isRegister = contactEntity.isRegister
//    }

    public struct Res: Codable {
        public var id: String?
        public var identifier: String
        public var phoneNumber: String
        public var fullName: String?
        public var avatar: String?
        public var isRegister: Bool?
        public var userId: String

        public init(_ contact: Contact) {
            self.id = contact.id
            self.identifier = contact.identifier
            self.userId = contact.userId ?? String.empty
            self.phoneNumber = contact.phoneNumber
            self.fullName = contact.fullName
            self.avatar = contact.avatar
            self.isRegister = contact.isRegister!
            self.userId = contact.userId!
        }

    }

}

extension Contact: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(phoneNumber)
        hasher.combine(avatar)
    }

    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber && lhs.avatar == rhs.avatar
    }
}

extension Contact.Res: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(phoneNumber)
        hasher.combine(avatar)
    }

    public static func == (lhs: Contact.Res, rhs: Contact.Res) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber && lhs.avatar == rhs.avatar
    }
}

public struct CreateContact: Codable {
  public var items: [Contact]
}
