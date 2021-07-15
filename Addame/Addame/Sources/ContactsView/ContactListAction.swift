//
//  ContactListAction.swift
//  
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import SharedModels
import HttpRequest
import ChatView
import Contacts

// public enum ChatAction: Equatable {}

public enum ContactListAction: Equatable {
  case onAppear
  case contactRow(id: String, action: ContactRowAction)
  case contactsResponse(Result<[Contact], HTTPError>)
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
