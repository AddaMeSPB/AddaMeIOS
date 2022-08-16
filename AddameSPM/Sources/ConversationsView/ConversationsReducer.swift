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
import AddaSharedModels
import SwiftUI
import WebSocketClient
import WebSocketClientLive
import BSON

// swiftlint:disable:next line_length superfluous_disable_command
public let conversationsReducer = Reducer<
  ConversationsState, ConversationsAction, ConversationEnvironment
> { state, action, environment in

  var fetchMoreConversations: Effect<ConversationsAction, Never> {
          let query = QueryItem(page: state.currentPage, per: 10)

        return .task {
            do {
                let conversations = try await environment.conversationClient.list(query)
                return ConversationsAction.conversationsResponse(conversations)
            } catch {
               return ConversationsAction.conversationsResponseError(HTTPRequest.HRError.networkError(error))
            }
        }
  }

  func createOrFine() -> Effect<ConversationsAction, Never> {

    guard let createConversation = state.createConversation else {
      // fire alert
      return .none
    }

    print(#line, "createConversation", createConversation)

      return .task {
          do {
              let response = try await environment.conversationClient.create(createConversation)
              return ConversationsAction.conversationResponse(.success(response))
          } catch {
              return  ConversationsAction.conversationResponse(.failure(HTTPRequest.HRError.networkError(error)))
          }
      }
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

  case .onDisAppear:
      state.canLoadMorePages = true
      return .none

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

    print(#line, state.conversation as Any)
    state.chatState = present ? ChatState(conversation: state.conversation) : nil
    return .none

  case let .contactsView(isPresented: present):

    state.contactsState = present ? ContactsState() : nil
    return .none

  case let .conversationsResponse(response):

      state.isLoadingPage = false

      response.items.forEach {
          if state.conversations[id: $0.id] != $0 {
              state.conversations.append($0)
          }
      }

      if state.conversations.isEmpty {
          state.conversations.append(contentsOf: response.items)
      }

      var newConversations = state.conversations.filter { $0.lastMessage != nil }
      newConversations.sort(by: { $0.lastMessage?.createdAt?.compare($1.createdAt ?? Date()) == .orderedDescending })
      state.conversations = newConversations

      state.canLoadMorePages = state.conversations.count < response.metadata.total
      if state.canLoadMorePages {
          state.currentPage += 1
      }

    return .none

  case let .conversationsResponseError(error):
      state.isLoadingPage = false
      state.alert = .init(title: TextState("Error happens \(error.description)"))
    return .none

  case let .updateLastConversation(messageResponse):
      print(#line, messageResponse.conversationId)
      let updatedIndex = state.conversations.firstIndex(where: { $0.id == messageResponse.id })
      state.conversations[id: messageResponse.conversationId]?.lastMessage = messageResponse

      state.conversations.sort()
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

      state.createConversation = ConversationCreate(
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
  state: .keyPath(\.chatState),
  id: .notNil(),
  action: /ConversationsAction.chat,
  environment: { _ in ChatEnvironment.live }
)
.presenting(
  contactsReducer,
  state: .keyPath(\.contactsState),
  id: .notNil(),
  action: /ConversationsAction.contacts,
  environment: { _ in ContactsEnvironment.live }
)
