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

import AddaSharedModels

extension ContactClient {
  public static let notDetermined = Self(
    authorization: {
        CNAuthorizationStatus.notDetermined
    },
    buidContacts: {
        MobileNumbersInput(mobileNumber: [""])
    }
  )

  public static let restricted = Self(
    authorization: { CNAuthorizationStatus.restricted },
    buidContacts: { MobileNumbersInput(mobileNumber: [""]) }
  )

  public static let denied = Self(
    authorization: { CNAuthorizationStatus.denied },
    buidContacts: { MobileNumbersInput(mobileNumber: [""]) }
  )

  public static let authorized = Self(
    authorization: { CNAuthorizationStatus.authorized },
    buidContacts: { MobileNumbersInput(mobileNumber: ["+79218821217"]) }
  )
}
