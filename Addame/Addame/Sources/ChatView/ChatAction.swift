//
//  ChatAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SharedModels
import HttpRequest
import Foundation
import WebSocketClient

public enum MessageAction: Equatable {}

public enum ChatAction: Equatable {
  case onAppear
  case alertDismissed
  case conversation(ConversationResponse.Item?)
  case messages(Result<ChatMessageResponse, HTTPError>)
  case fetchMoreMessageIfNeeded(currentItem: ChatMessageResponse.Item?)
  case fetchMoreMessage(currentItem: ChatMessageResponse.Item)
  case message(index: ChatMessageResponse.Item.ID, action: MessageAction)
  case sendResponse(NSError?)
  case webSocket(WebSocketClient.Action)
  case pingResponse(NSError?)
  case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
  case messageToSendChanged(String)
  case sendButtonTapped
}

public extension ChatAction {
  // swiftlint:disable cyclomatic_complexity
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
    case let .fetchMoreMessageIfNeeded(currentItem: currentItem):
      return .fetchMoreMessageIfNeeded(currentItem: currentItem)
    case let .fetchMoreMessage(currentItem: item):
      return .fetchMoreMessage(currentItem: item)
    case let .message(index, action):
      return .message(index: index, action: action)
    case .sendResponse(let error):
      return .sendResponse(error)
    case .webSocket(let action):
      return .webSocket(action)
    case .pingResponse(let error):
      return .pingResponse(error)
    case .receivedSocketMessage(let result):
      return .receivedSocketMessage(result)
    case .messageToSendChanged(let string):
      return .messageToSendChanged(string)
    case .sendButtonTapped:
      return .sendButtonTapped
    }
  }
}
