//
//  ChatAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SharedModels
import HttpRequest

public enum MessageAction: Equatable {}

public enum ChatAction: Equatable {
  case onAppear
  case alertDismissed
  case conversation(ConversationResponse.Item?)
  case messages(Result<ChatMessageResponse, HTTPError>)
  case fetchMoreMessagIfNeeded(currentItem: ChatMessageResponse.Item?)
  case message(index: String?, action: MessageAction)
}

public extension ChatAction {
  static func view(_ localAction: ChatView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case .conversation(let conversation):
      return .conversation(conversation)
    case .messages(let messages):
      return .messages(messages)
    case .fetchMoreMessagIfNeeded(currentItem: let currentItem):
      return .fetchMoreMessagIfNeeded(currentItem: currentItem)
    case let .message(index, action):
      return .message(index: index, action: action)
    }
  }
}

// public extension ProfileAction {
//  static func view(_ localAction: ProfileView.ViewAction) -> Self {
