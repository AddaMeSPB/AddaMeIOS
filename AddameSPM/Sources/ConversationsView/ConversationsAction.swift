//
//  ConversationAction.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import ChatView
import ComposableArchitecture
import ContactsView
import Foundation
import HTTPRequestKit
import SharedModels

public enum ConversationsAction: Equatable {
  case onAppear
  case alertDismissed
  case chatRoom(index: String, action: ConversationAction)
  case conversationTapped(ConversationResponse.Item)
  case chatView(isPresented: Bool)
  case contactsView(isPresented: Bool)
  case chat(ChatAction)
  case contacts(ContactsAction)

  case conversationsResponse(Result<ConversationResponse, HTTPRequest.HRError>)
  case conversationResponse(Result<ConversationResponse.Item, HTTPRequest.HRError>)
  case fetchMoreConversationIfNeeded(currentItem: ConversationResponse.Item?)
}

extension ConversationsAction {
  static func view(_ localAction: ConversationsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return onAppear
    case let .conversationsResponse(res):
      return conversationsResponse(res)
    case let .fetchMoreConversationIfNeeded(currentItem):
      return fetchMoreConversationIfNeeded(currentItem: currentItem)
    case .alertDismissed:
      return alertDismissed
    case let .conversationTapped(conversationItem):
      return conversationTapped(conversationItem)
    case let .chat(action):
      return chat(action)
    case let .contacts(action):
      return contacts(action)
    case let .chatView(isPresented: isPresented):
      return .chatView(isPresented: isPresented)
    case let .contactsView(isPresented: isPresented):
      return .contactsView(isPresented: isPresented)
    }
  }
}

public enum ConversationAction: Equatable {
  case chat(ChatAction)
}
