//
//  ContactsAction.swift
//
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import ChatView
import Contacts
import HTTPRequestKit
import AddaSharedModels

// public enum ChatAction: Equatable {}

public enum ContactsAction: Equatable {
  case onAppear
  case alertDismissed
  case contact(id: String?, action: ContactRowAction)
  case contactsAuthorizationStatus(CNAuthorizationStatus)
  case contactsResponse(Result<[ContactOutPut], HTTPRequest.HRError>)

  case moveToChatRoom(Bool)
  case chatWith(name: String, phoneNumber: String)
}

// extension ContactsAction {
//  static func view(_ localAction: ContactsView.ViewAction) -> Self {
//    switch localAction {
//    case .onAppear:
//      return .onAppear
//    case .alertDismissed:
//      return .alertDismissed
//    case .moveChatRoom(let bool):
//      return .moveChatRoom(bool)
//    case .chat(let action):
//      return .chat(action)
//    case .contactsAuthorizationStatus(let status):
//      return .contactsAuthorizationStatus(status)
//    case .contactsResponse(let response):
//      return .contactsResponse(response)
//    case let .chatRoom(index: index, action: action):
//      return .chatRoom(index: index, action: action)
//    case let .chatWith(name: name, phoneNumber: phoneNumber):
//      return .chatWith(name: name, phoneNumber: phoneNumber)
//    }
//  }
// }
//
