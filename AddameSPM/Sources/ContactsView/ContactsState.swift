//
//  ContactsAction.swift
//
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import ChatView
import ComposableArchitecture
import Contacts
import HTTPRequestKit
import SharedModels

public struct ContactsState: Equatable {
  public init(
    alert: AlertState<ContactsAction>? = nil,
    contacts: IdentifiedArrayOf<ContactRowState> = [],
    isAuthorizedContacts: Bool = false,
    invalidPermission: Bool = false,
    isLoading: Bool = false,
    isActivityIndicatorVisible: Bool = false
  ) {
    self.alert = alert
    self.contacts = contacts
    self.isAuthorizedContacts = isAuthorizedContacts
    self.invalidPermission = invalidPermission
    self.isLoading = isLoading
    self.isActivityIndicatorVisible = isActivityIndicatorVisible
  }

  public var alert: AlertState<ContactsAction>?
  public var contacts: IdentifiedArrayOf<ContactRowState> = []
  public var isAuthorizedContacts: Bool = false
  public var invalidPermission: Bool = false
  public var isLoading: Bool = false
  public var isActivityIndicatorVisible: Bool = false

  public enum Action: Equatable {
    case didChangeAuthorization(CNAuthorizationStatus)
  }
}

// extension ContactsState {
//  var view: ContactsView.ViewState {
//    ContactsView.ViewState(
//      alert: self.alert,
//      contacts: self.contacts,
//      invalidPermission: self.invalidPermission,
//      isLoading: self.isLoading
//    )
//  }
// }

// swiftlint:disable line_length superfluous_disable_command
extension ContactsState {
  public static let contactsPlaceholder = Self(
    contacts: [
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd621", phoneNumber: "+79211111111", fullName: "Saroar")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd622", phoneNumber: "+79211111112", fullName: "Anastasia"
        )),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd623", phoneNumber: "+79211111113", fullName: "Rafael")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd624", phoneNumber: "+79211111114", fullName: "Masum")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd625", phoneNumber: "+79211111115", fullName: "Olga")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd626", phoneNumber: "+79211111116", fullName: "Alla")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd627", phoneNumber: "+79211111117", fullName: "Denis")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd628", phoneNumber: "+79211111118", fullName: "Nikita")),
      .init(
        id: UUID().uuidString, isMoving: false,
        contact: .init(
          identifier: "5fd75df879983965ad5cd629", phoneNumber: "+79211111119", fullName: "Krill"))
    ]
  )
}
