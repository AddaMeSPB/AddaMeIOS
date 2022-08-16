//
//  ChatAction.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation
import HTTPRequestKit
import AddaSharedModels
import WebSocketClient

public enum MessageAction: Equatable {}

public enum ChatAction: Equatable {
  case onAppear
  case alertDismissed
  case conversation(ConversationOutPut?)
  case messagesResponse(MessagePage)
  case messagesResponseError(HTTPRequest.HRError)

  case fetchMoreMessageIfNeeded(currentItem: MessageItem?)
  case fetchMoreMessage(currentItem: MessageItem)
  case message(index: MessageItem.ID, action: MessageAction)
  case sendResponse(NSError?)
  case webSocket(WebSocketClient.Action)
  case pingResponse(NSError?)
  case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
  case messageToSendChanged(String)
  case sendButtonTapped
}

extension ChatAction {
  // swiftlint:disable cyclomatic_complexity
  public static func view(_ localAction: ChatView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case let .conversation(conversation):
      return .conversation(conversation)
    case let .fetchMoreMessageIfNeeded(currentItem: currentItem):
      return .fetchMoreMessageIfNeeded(currentItem: currentItem)
    case let .fetchMoreMessage(currentItem: item):
      return .fetchMoreMessage(currentItem: item)
    case let .message(index, action):
      return .message(index: index, action: action)
    case let .sendResponse(error):
      return .sendResponse(error)
    case let .webSocket(action):
      return .webSocket(action)
    case let .pingResponse(error):
      return .pingResponse(error)
    case let .receivedSocketMessage(result):
      return .receivedSocketMessage(result)
    case let .messageToSendChanged(string):
      return .messageToSendChanged(string)
    case .sendButtonTapped:
      return .sendButtonTapped
    }
  }
}
