//
//  ConversationsAction.swift
//  
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import Foundation
import ComposableArchitecture
import AddaMeModels
import FuncNetworking

public enum ConversationsAction: Equatable {
  case onAppear
  case alertDismissed
  case chatRoom(index: String, action: ConversationAction)
  case conversationTapped(ConversationResponse.Item)
  case moveChatRoom(Bool)
  case chat(ChatAction)
  
  case conversationsResponse(Result<ConversationResponse, HTTPError>)
  case fetchMoreConversationIfNeeded(currentItem: ConversationResponse.Item?)
}

extension ConversationsAction {
  static func view(_ localAction: ConversationView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return self .onAppear
    case .moveChatRoom(let bool):
      return self .moveChatRoom(bool)
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
    }
  }
}

public enum ConversationAction: Equatable {}
