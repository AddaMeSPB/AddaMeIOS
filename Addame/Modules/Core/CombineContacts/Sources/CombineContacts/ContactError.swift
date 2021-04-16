//
//  ContactError.swift
//  
//
//  Created by Saroar Khandoker on 25.03.2021.
//

import Foundation

public struct ContactError: Error {
  var description: String
  public let reason: Error?
  
  public static var entityTypeError: Self {
    .init(description: "CNEntityType Contacts Error", reason: nil)
  }
  
  public static var identifierAndKeysToFetchError: Self {
    .init(description: "Identifier and KeysToFetch Error Contacts", reason: nil)
  }
  
  public static var predicateAndKeysToFetchError: Self {
    .init(description: "Predicate and KeysToFetch Error Contacts", reason: nil)
  }
  
  public static var groupsMatchingPredicateError: Self {
    .init(description: "Groups Matching Predicate Error Contacts", reason: nil)
  }

  public static var containersMatchingPredicateError: Self {
    .init(description: "Containers Matching Predicate Error Contacts", reason: nil)
  }
  
  public static var enumerateContactsWithFetchRequestContactPointerError: Self {
    .init(description: "Enumerate Contacts With Fetch Request Contact Pointer Error Contacts", reason: nil)
  }

  public static var phoneNumberKitParseError: Self {
    .init(description: "PhoneNumberKitParse Contacts Error", reason: nil)
  }

}

