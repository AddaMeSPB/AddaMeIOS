//
//  ContactListAction.swift
//
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import ChatView
import Contacts
import AddaSharedModels
import ComposableArchitecture

// public enum ChatAction: Equatable {}

public enum ContactListAction: Equatable {
  case onAppear
    case contactRow(id: String, action: ContactRow.Action)
  case contactsResponse(TaskResult<[ContactOutPut]>)
}

// extension ContactListAction {
//  static func view(_ localAction: ContactsView.ViewAction) -> Self {
//    switch localAction {
//    case .onAppear:
//      return .onAppear
//    case .alertDismissed:
//      return .alertDismissed
//    case .contactsAuthorizationStatus(let status):
//      return .contactsAuthorizationStatus(status)
//    case .contactsResponse(let response):
//      return .contactsResponse(response)
//    case let .contactRow(id: id, action: action):
//      return .contactRow(id: id, action: action)
//    }
//  }
// }
