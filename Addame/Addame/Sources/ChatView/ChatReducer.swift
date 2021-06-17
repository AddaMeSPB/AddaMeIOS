//
//  ChatReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import SharedModels

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment> { state, action, environment in

  func fetchMoreMessages() -> Effect<ChatAction, Never> {

    guard let conversationsID = state.conversation?.id else {
      print(#line, "Conversation id missing")
      return .none
    }

    let query = QueryItem(page: "\(state.currentPage)", per: "60")

    return environment.chatClient
      .messages(query, conversationsID, "/by/conversations/\(conversationsID)")
      .retry(3)
      .receive(on: environment.mainQueue.animation(.default))
      .catchToEffect()
      .map(ChatAction.messages)
  }

  switch action {

  case .onAppear:

    return fetchMoreMessages()

  case .alertDismissed:
    state.alert = nil
    return .none

  case .conversation(let converstion):
    state.conversation = converstion
    return fetchMoreMessages()

  case .messages(.success(let response)):
    state.canLoadMorePages = state.messages.count < response.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    let combineMessageResults = (response.items + state.messages).uniqElemets().sorted()
    state.messages = .init(combineMessageResults)
//    self.messageSubject.send(combineMessageResults)

    return .none

  case .messages(.failure(let error)):
    state.alert = .init(title: TextState("\(error.description)") )
    return .none

  case .fetchMoreMessagIfNeeded(currentItem: let currentItem):

    guard let item = currentItem, state.messages.count > 10 else {
      return fetchMoreMessages()
    }

    let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -10)
    if state.messages.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreMessages()
    }

    return .none

  }
}
