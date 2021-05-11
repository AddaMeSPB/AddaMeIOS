//
//  ConversationReducer.swift
//  
//
//  Created by Saroar Khandoker on 20.04.2021.
//

import Combine
import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import ChatView

import ChatClient
import ChatClientLive

import WebsocketClient
import WebsocketClientLive

public let conversationReducer = Reducer<ConversationsState, ConversationsAction, ConversationEnvironment>.combine(
  chatReducer
    .optional()
    .pullback(
    state: \.chatState,
    action: /ConversationsAction.chat,
    environment: { _ in
      ChatEnvironment(
        chatClient: ChatClient.live(api: .build),
        websocket: WebsocketEnvironment(
          websocketClient: WebsocketClient.live(api: .build),
          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        ),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    }
  ), Reducer { state, action, environment in
      func fetchMoreConversations() -> Effect<ConversationsAction, Never> {
    
        let query = QueryItem(page: "\(state.currentPage)", per: "10")
    
        return environment.conversationClient.list(query, "")
          .retry(3)
          .receive(on: environment.mainQueue.animation(.default))
          .catchToEffect()
          .map(ConversationsAction.conversationsResponse)
    
      }
    
    switch action {

    case .onAppear:

      return fetchMoreConversations()

    case .fetchMoreConversationIfNeeded(let currentItem):

      guard let item = currentItem, state.conversations.count > 7 else {
        return fetchMoreConversations()
      }

      let threshouldIndex = state.conversations.index(state.conversations.endIndex, offsetBy: -7)

      if state.conversations.firstIndex(where: { $0.id == item.id } ) == threshouldIndex {
        return fetchMoreConversations()
      }

      return .none

    case .moveChatRoom(let present):
      state.chatState = present ? ChatState(conversation: state.conversation) : nil
      return .none

    case .conversationsResponse(.success(let response)):

      guard !state.isLoadingPage && state.canLoadMorePages else { return .none }

      state.isLoadingPage = true

      state.canLoadMorePages = state.conversations.count < response.metadata.total
      state.isLoadingPage = false
      state.currentPage += 1

      let combineConversationResults = (response.items + state.conversations)
        .filter({ $0.lastMessage != nil })
        .uniqElemets()
        .sorted()

      state.conversations = .init(combineConversationResults)
  //    state.conversationsSubject.send(combineConversationResults)
      return .none

    case .conversationsResponse(.failure(let error)):
      state.alert = .init(title: TextState("Error happens \(error.description)"))
      return .none

    case .alertDismissed:
      state.alert = nil
      return .none

    case .conversationTapped(let conversationItem):
      state.conversation = conversationItem

      return .none
    case .chat(let conversation):

      return .none
    case .chatRoom(index: let index, action: let action):
      
      return .none
    }
  }
)

//public let conversationReducer = Reducer<ConversationsState, ConversationsAction, ConversationEnvironment>.combine(
//  chatReducer.pullback(
//    state: \.chat,
//    action: /ConversationAction.chat,
//    environment:
//
//    ), Reducer { state, action, environment in
//
//  func fetchMoreConversations() -> Effect<ConversationsAction, Never> {
//
//    let query = QueryItem(page: "\(state.currentPage)", per: "10")
//
//    return environment.conversationClient.list(query, "")
//      .retry(3)
//      .receive(on: environment.mainQueue.animation(.default))
//      .catchToEffect()
//      .map(ConversationsAction.conversationsResponse)
//
//  }
//
//  switch action {
//
//  case .onAppear:
//
//    return fetchMoreConversations()
//
//  case .fetchMoreConversationIfNeeded(let currentItem):
//
//    guard let item = currentItem, state.conversations.count > 7 else {
//      return fetchMoreConversations()
//    }
//
//    let threshouldIndex = state.conversations.index(state.conversations.endIndex, offsetBy: -7)
//
//    if state.conversations.firstIndex(where: { $0.id == item.id } ) == threshouldIndex {
//      return fetchMoreConversations()
//    }
//
//    return .none
//
//  case .moveChatRoom(let present):
//    state.chatState = present ? ChatState(conversation: state.conversation) : nil
//    return .none
//
//  case .conversationsResponse(.success(let response)):
//
//    guard !state.isLoadingPage && state.canLoadMorePages else { return .none }
//
//    state.isLoadingPage = true
//
//    state.canLoadMorePages = state.conversations.count < response.metadata.total
//    state.isLoadingPage = false
//    state.currentPage += 1
//
//    let combineConversationResults = (response.items + state.conversations)
//      .filter({ $0.lastMessage != nil })
//      .uniqElemets()
//      .sorted()
//
//    state.conversations = .init(combineConversationResults)
////    state.conversationsSubject.send(combineConversationResults)
//    return .none
//
//  case .conversationsResponse(.failure(let error)):
//    state.alert = .init(title: TextState("Error happens \(error.description)"))
//    return .none
//
//  case .alertDismissed:
//    state.alert = nil
//    return .none
//
//  case .conversationTapped(let conversationItem):
//    state.conversation = conversationItem
//
//    return .none
//  case .chat(let conversation):
//
//    return .none
//  }
//})
