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
import ContactsView

import ChatClient
import ChatClientLive

import ContactClient
import ContactClientLive
import CoreDataClient

import WebSocketClient
import WebSocketClientLive

// swiftlint:disable:next line_length
public let conversationsReducer = Reducer<ConversationsState, ConversationsAction, ConversationEnvironment> { state, action, environment in

  var fetchMoreConversations: Effect<ConversationsAction, Never> {

    let query = QueryItem(page: "\(state.currentPage)", per: "10")

    return environment.conversationClient.list(query, "")
      .retry(3)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ConversationsAction.conversationsResponse)
  }

  func createOrFine() -> Effect<ConversationsAction, Never> {
    return environment.conversationClient.create(state.createConversation!, "")
      .retry(3)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ConversationsAction.conversationResponse)
  }

  func presentChatView() -> Effect<ConversationsAction, Never> {
    return Effect(value: ConversationsAction.chatView(isPresented: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()
  }

  switch action {

  case .onAppear:

    return fetchMoreConversations

  case .fetchMoreConversationIfNeeded(let currentItem):

    guard let item = currentItem, state.conversations.count > 7 else {
      return fetchMoreConversations
    }

    let threshouldIndex = state.conversations.index(state.conversations.endIndex, offsetBy: -7)

    if state.conversations.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreConversations
    }

    return .none

  case .chatView(isPresented: let present):
    state.chatState = present ? ChatState(conversation: state.conversation) : nil
    return .none

  case .contactsView(isPresented: let present):

    state.contactsState = present ? ContactsState() : nil
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
  case let .chatRoom(index: index, action: chatRoomAction):

    return .none

  case .chat(let chatAction):

    return .none

  case .contacts(let contactsAction):
    switch contactsAction {

    case .onAppear, .alertDismissed:
      return .none
    case .moveChatRoom(let present):
      return .none
    case .contactsResponse(.success(let contacts)):
      return .none
    case .contactsResponse(.failure(let error)):
      return .none

    case .contactsAuthorizationStatus(.notDetermined),
         .contactsAuthorizationStatus(.denied),
         .contactsAuthorizationStatus(.restricted),
         .contactsAuthorizationStatus(.authorized),
         .contactsAuthorizationStatus(_):
      return .none

    case .chat(_):
      return .none

    case let .chatRoom(index: index, action: action):
      return .none

    case let .chatWith(name: name, phoneNumber: phoneNumber):
      state.createConversation = CreateConversation(
        title: "currenUser + \(name)",
        type: .oneToOne, opponentPhoneNumber: phoneNumber
      )

      return createOrFine()

    case .none:
      return .none
    }

  case .conversationResponse(.success(let response)):
    print(#line, "conversation: \(response)")
//    state.contactsState = nil
    state.conversation = response

    return presentChatView()

  case .conversationResponse(.failure(let error)):
    return .none
  }
}
.presents(
  chatReducer,
  state: \.chatState,
  action: /ConversationsAction.chat,
  environment: {
    ChatEnvironment(
      chatClient: ChatClient.live(api: .build),
      websocketClient: .live,
      mainQueue: $0.mainQueue
    )
  }
)
.presents(
  contactsReducer,
  state: \.contactsState,
  action: /ConversationsAction.contacts,
  environment: {
    ContactsEnvironment(
      coreDataClient: CoreDataClient(
        contactClient: ContactClient.live(api: .build)
      ),
      backgroundQueue: $0.backgroundQueue,
      mainQueue: $0.mainQueue
    )
  }
)
