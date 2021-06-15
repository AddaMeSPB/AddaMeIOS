//
//  ContactEntity+CoreDataProperties.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 01.12.2020.
//
//

import Foundation
import CoreData

extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var avatar: String?
    @NSManaged public var fullName: String
    @NSManaged public var id: String?
    @NSManaged public var identifier: String
    @NSManaged public var isRegister: Bool
    @NSManaged public var phoneNumber: String
    @NSManaged public var userId: String

}

extension ContactEntity: Identifiable {}
