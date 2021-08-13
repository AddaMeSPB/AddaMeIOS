//
//  ConversationAction.swift
//  
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import Foundation
import ComposableArchitecture
import SharedModels
import HttpRequest
import ChatView
import ContactsView

public enum ConversationsAction: Equatable {
  case onAppear
  case alertDismissed
  case chatRoom(index: String, action: ConversationAction)
  case conversationTapped(ConversationResponse.Item)
  case chatView(isPresented: Bool)
  case contactsView(isPresented: Bool)
  case chat(ChatAction)
  case contacts(ContactsAction)

  case conversationsResponse(Result<ConversationResponse, HTTPError>)
  case conversationResponse(Result<ConversationResponse.Item, HTTPError>)
  case fetchMoreConversationIfNeeded(currentItem: ConversationResponse.Item?)
}

extension ConversationsAction {
  static func view(_ localAction: ConversationsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return self .onAppear
    case .conversationsResponse(let res):
      return self.conversationsResponse(res)
    case .fetchMoreConversationIfNeeded(let currentItem):
      return self.fetchMoreConversationIfNeeded(currentItem: currentItem)
    case .alertDismissed:
      return self.alertDismissed
    case .conversationTapped(let conversationItem):
      return self.conversationTapped(conversationItem)
    case .chat(let action):
      return self.chat(action)
    case .contacts(let action):
      return self.contacts(action)
    case .chatView(isPresented: let isPresented):
      return .chatView(isPresented: isPresented)
    case .contactsView(isPresented: let isPresented):
      return .contactsView(isPresented: isPresented)
    }
  }
}

public enum ConversationAction: Equatable {
  case chat(ChatAction)
}
