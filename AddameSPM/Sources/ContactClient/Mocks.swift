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
import HTTPRequestKit
import AddaSharedModels

extension ContactClient {
  public static let notDetermined = Self(
    authorization: {
        CNAuthorizationStatus.notDetermined
    },
    buidContacts: {
        MobileNumbersInput(mobileNumber: [""])
    },
    getRegisterUsersFromServer: { _ in
        [UserOutput.withNumber, UserOutput.withFirstName, UserOutput.withAttachments]
    }
  )

  public static let restricted = Self(
    authorization: { CNAuthorizationStatus.restricted },
    buidContacts: { MobileNumbersInput(mobileNumber: [""]) },
    getRegisterUsersFromServer: { _ in
        [UserOutput.withNumber, UserOutput.withFirstName, UserOutput.withAttachments]
    }
  )

  public static let denied = Self(
    authorization: { CNAuthorizationStatus.denied },
    buidContacts: { MobileNumbersInput(mobileNumber: [""]) },
    getRegisterUsersFromServer: { _ in
        [UserOutput.withNumber, UserOutput.withFirstName, UserOutput.withAttachments]
    }
  )

  public static let authorized = Self(
    authorization: { CNAuthorizationStatus.authorized },
    buidContacts: { MobileNumbersInput(mobileNumber: [""]) },
    getRegisterUsersFromServer: { _ in
        [UserOutput.withNumber, UserOutput.withFirstName, UserOutput.withAttachments]
    }
  )
}
