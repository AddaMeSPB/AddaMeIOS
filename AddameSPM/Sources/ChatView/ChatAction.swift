//
//  ChatAction.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation

import AddaSharedModels



extension Chat.Action {
  // swiftlint:disable cyclomatic_complexity
  public static func view(_ localAction: ChatView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case let .fetchMoreMessageIfNeeded(currentItem: currentItem):
      return .fetchMoreMessageIfNeeded(currentItem: currentItem)
    case let .fetchMoreMessage(currentItem: item):
      return .fetchMoreMessage(currentItem: item)
    case let .message(index, action):
      return .message(index: index, action: action)
    case .messagesResponse(let response):
        return .messagesResponse(response)
    case .webSocketReducer(let wsra):
        return .webSocketReducer(wsra)
    case .chatButtom(let cb):
        return .chatButtom(cb)
    }
  }
}
