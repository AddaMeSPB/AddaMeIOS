//
//  ContactEntityExtension.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 01.12.2020.
//

import CoreData
import Foundation
import FoundationExtension
import SharedModels

extension ContactEntity {
  static func allContactsFetchRequest() -> NSFetchRequest<ContactEntity> {
    let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "phoneNumber", ascending: true)]
    print(#line, request)
    return request
  }
}

extension ContactEntity {
  static var registerContactsFetchRequest: NSFetchRequest<ContactEntity> {
    let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
    request.predicate = NSPredicate(format: "isRegister == true")
    request.sortDescriptors = [NSSortDescriptor(key: "fullName", ascending: true)]

    return request
  }
}

extension ContactEntity: ManagedModel {
  public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }

  public static func findOrCreate(withData data: APIData, in context: NSManagedObjectContext)
    -> ContactEntity
  {
    guard let content = data as? Contact else {
      fatalError("Incorrent API response")
    }

    let predicate = NSPredicate(format: "%K == %@", #keyPath(phoneNumber), content.phoneNumber)
    let contact = ContactEntity.findOrCreate(in: context, matching: predicate) { contact in
      contact.id = content.id ?? String.empty
      contact.fullName = content.fullName ?? String.empty
      contact.avatar = content.avatar
      contact.identifier = content.identifier
      contact.isRegister = content.isRegister ?? false
      contact.userId = content.userId ?? String.empty
      contact.phoneNumber = content.phoneNumber
    }

    contact.id = content.id ?? String.empty
    contact.fullName = content.fullName ?? String.empty
    contact.avatar = content.avatar
    contact.identifier = content.identifier
    contact.isRegister = content.isRegister ?? false
    contact.userId = content.userId ?? String.empty
    contact.phoneNumber = content.phoneNumber

    return contact
  }

  public static var defaultSortDescriptors: [NSSortDescriptor] {
    return [NSSortDescriptor(key: #keyPath(isRegister), ascending: true)]
  }
}

extension ContactEntity {
  public func contact() -> Contact {
    return Contact(
      id: id, identifier: identifier,
      userId: userId, phoneNumber: phoneNumber,
      fullName: fullName, avatar: avatar,
      isRegister: isRegister
    )
  }
}
