//
//  ContactsAction.swift
//
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import ChatView
import ComposableArchitecture
import Contacts

import AddaSharedModels
import BSON

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
extension ContactsReducer.State {
    public static let contactsPlaceholder = Self(isAuthorizedContacts: true)
}
