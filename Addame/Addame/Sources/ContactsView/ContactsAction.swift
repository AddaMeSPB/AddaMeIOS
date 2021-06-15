//
//  ContactsAction.swift
//  
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import SharedModels
import HttpRequest
import ChatView
import Contacts

//public enum ChatAction: Equatable {}

public enum ContactAction: Equatable {
  case chat(ChatAction)
}

public enum ContactsAction: Equatable {
  case onAppear
  case alertDismissed
  case moveChatRoom(Bool)
  case chat(ChatAction?)
  case chatRoom(index: String?, action: ContactAction)
  case chatWith(name: String, phoneNumber: String)
  
  case contactsAuthorizationStatus(CNAuthorizationStatus)
  
  case contactsResponse(Result<[Contact], HTTPError>)
}

extension ContactsAction {
  static func view(_ localAction: ContactsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case .moveChatRoom(let bool):
      return .moveChatRoom(bool)
    case .chat(let action):
      return .chat(action)
    case .contactsAuthorizationStatus(let status):
      return .contactsAuthorizationStatus(status)
    case .contactsResponse(let response):
      return .contactsResponse(response)
    case let .chatRoom(index: index, action: action):
      return .chatRoom(index: index, action: action)
    case .chatWith(name: let name, phoneNumber: let phoneNumber):
      return .chatWith(name: name, phoneNumber: phoneNumber)
    }
  }
}
