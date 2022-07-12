//
//  ConversationReducer.swift
//
//
//  Created by Saroar Khandoker on 20.04.2021.
//

import ChatView
import Combine
import ComposableArchitecture
import ComposablePresentation
import ComposableArchitectureHelpers
import ContactsView
import HTTPRequestKit
import SharedModels
import SwiftUI
import WebSocketClient
import WebSocketClientLive

// swiftlint:disable:next line_length superfluous_disable_command
public let conversationsReducer = Reducer<
  ConversationsState, ConversationsAction, ConversationEnvironment
> { state, action, environment in

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

    guard let createConversation = state.createConversation else {
      // fire alert
      return .none
    }

    print(#line, "createConversation", createConversation)
    return environment.conversationClient.create(createConversation, "")
      .retry(3)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ConversationsAction.conversationResponse)
  }

  func presentChatView() -> Effect<ConversationsAction, Never> {
    state.chatState = nil
    return Effect(value: ConversationsAction.chatView(isPresented: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()
  }

  switch action {
  case .onAppear:

    state.isLoadingPage = true
    return fetchMoreConversations

  case let .fetchMoreConversationIfNeeded(currentItem):

    guard !state.isLoadingPage, state.canLoadMorePages else {
      return .none
    }

    guard let item = currentItem, state.conversations.count > 7 else {
      return fetchMoreConversations
    }

    let threshouldIndex = state.conversations.index(state.conversations.endIndex, offsetBy: -7)

    if state.conversations.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreConversations
    }

    return .none

  case let .chatView(isPresented: present):

      print(#line, state.conversation)
    state.chatState = present ? ChatState(conversation: state.conversation) : nil
    return .none

  case let .contactsView(isPresented: present):

    state.contactsState = present ? ContactsState() : nil
    return .none

  case let .conversationsResponse(.success(response)):

    state.canLoadMorePages = state.conversations.count < response.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    let combineConversationResults = (response.items + state.conversations)
      .filter { $0.lastMessage != nil }
      .uniqElemets()
      .sorted()

    state.conversations = .init(uniqueElements: combineConversationResults)

    return .none

  case let .conversationsResponse(.failure(error)):
    state.isLoadingPage = false
    state.alert = .init(title: TextState("Error happens \(error.description)"))
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none

  case let .conversationTapped(conversationItem):
    state.conversation = conversationItem

    return presentChatView()
  case let .chatRoom(index: index, action: chatRoomAction):

    return .none

  case let .chat(chatAction):
    return .none

  case let .conversationResponse(.success(response)):
    state.contactsState = nil
    state.conversation = response
    print(#line, "conversationResponse", response)
    return presentChatView()

  case let .conversationResponse(.failure(error)):
      print(error)
    return .none

  case let .contacts(.contact(id: id, action: action)):
    switch action {
    case let .moveToChatRoom(bool):
      print(#line, bool)
      return .none
    case let .chatWith(name: name, phoneNumber: phoneNumber):
        print(#line, name, phoneNumber)
      state.createConversation = CreateConversation(
        title: name,
        type: .oneToOne,
        opponentPhoneNumber: phoneNumber
      )

      return createOrFine()
    }

  case .contacts(.contactsAuthorizationStatus(_)):
    return .none
  case .contacts(.contactsResponse(_)):
    return .none
  case .contacts(.moveToChatRoom(_)):
    return .none
  case let .contacts(.chatWith(name: name, phoneNumber: phoneNumber)):
    return .none
  case .contacts(.onAppear):
    return .none
  case .contacts(.alertDismissed):
    return .none
  }
}
.presenting(
  chatReducer,
  state: \.chatState,
  action: /ConversationsAction.chat,
  environment: { _ in ChatEnvironment.live }
)
.presenting(
  contactsReducer,
  state: \.contactsState,
  action: /ConversationsAction.contacts,
  environment: { _ in ContactsEnvironment.live }
)
