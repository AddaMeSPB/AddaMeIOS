//
//  ChatReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation
import ComposableArchitecture
import FoundationExtension
import InfoPlist
import KeychainService
import AddaSharedModels
import HTTPRequestKit
import BSON

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment> {
  state, action, environment in

  var fetchMoreMessages: Effect<ChatAction, Never> {
      guard let conversationsID = state.conversation?.id.hexString else {
      print(#line, "Conversation id missing")
      return .none
    }

    let query = QueryItem(page: state.currentPage, per: 10)

      return .task {
          do {
              let messages = try await environment.chatClient.messages(query, conversationsID)
              return ChatAction.messagesResponse(messages)
          } catch {
             return ChatAction.messagesResponseError(HTTPRequest.HRError.networkError(error))
          }
      }

  }

  var receiveSocketMessageEffect: Effect<ChatAction, Never> {
      return environment.websocketClient.receive(environment.currentUser.id!.hexString)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ChatAction.receivedSocketMessage)
      .cancellable(id: environment.currentUser.id)
  }

  var sendPingEffect: Effect<ChatAction, Never> {
      return environment.websocketClient.sendPing(environment.currentUser.id!.hexString)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .delay(for: 10, scheduler: environment.mainQueue)
      .map(ChatAction.pingResponse)
      .eraseToEffect()
      .cancellable(id: environment.currentUser.id)
  }

  switch action {
  case .onAppear:
      // print(#line, state.conversation?.title)

    return fetchMoreMessages

  case .alertDismissed:
    state.alert = nil
    return .none

  case let .conversation(converstion):
    state.conversation = converstion
    return fetchMoreMessages

  case let .messagesResponse(response):

    state.isLoadingPage = false

      response.items.forEach {
          if state.messages[id: $0.id] != $0 {
              state.messages.append($0)
          } else if state.messages.isEmpty {
              state.messages.append(contentsOf: response.items)
          }
      }

      _ = state.messages
          .sorted(by: { $0.createdAt?.compare($1.createdAt ?? Date()) == .orderedDescending })

      state.canLoadMorePages = state.messages.count < response.metadata.total
      if state.canLoadMorePages {
        state.currentPage += 1
      }

    return .none

  case let .messagesResponseError(error):
    state.alert = .init(title: TextState("\(error.description)"))
    return .none

  case let .fetchMoreMessageIfNeeded(currentItem: currentItem):
    guard let item = currentItem, state.messages.count > 5 else {
      return fetchMoreMessages
    }

    let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -5) - 3
    if state.messages.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreMessages
    }
    return .none

  case let .fetchMoreMessage(currentItem: item):

    let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -7)
    if state.messages.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreMessages
    }
    return .none

  case let .sendResponse(error):
      if error != nil {
        state.alert = .init(title: .init("Could not send socket message. Try again."))
      }

      return .merge(
        receiveSocketMessageEffect,
        sendPingEffect
      )

  case let .webSocket(.didClose(code, _)):
    // state.connectivityState = .disconnected
    return .cancel(id: environment.currentUser.id)

  case let .webSocket(.didBecomeInvalidWithError(error)),
    let .webSocket(.didCompleteWithError(error)):
    // state.connectivityState = .disconnected

    if error != nil {
      state.alert = .init(title: .init("Disconnected from socket for some reason. Try again."))
    }
    return .cancel(id: environment.currentUser.id)

  case .webSocket(.didOpenWithProtocol):
    // state.connectivityState = .connected
    return .merge(
      receiveSocketMessageEffect,
      sendPingEffect
    )

  case .pingResponse:
    // Ping the socket again in 10 seconds
    return sendPingEffect

  case .receivedSocketMessage:
    return .none

  case let .messageToSendChanged(message):
    state.messageToSend = message

    return .none

  case .sendButtonTapped:
    let composedMessage = state.messageToSend
    state.messageToSend = ""

    guard let conversationsID = state.conversation?.id else {
      print(#line, "conversation id missing")
      return .none
    }

      guard let currentUserID = environment.currentUser.id?.hexString else {
        print(#line, "currentUser id missing")
        return .none
      }

      let localMessage = MessageItem(
        id: ObjectId(),
        conversationId: conversationsID,
        messageBody: composedMessage,
        messageType: .text,
        isRead: false,
        isDelivered: false,
        sender: environment.currentUser,
        recipient: nil,
        createdAt: nil, updatedAt: nil, deletedAt: nil
      )

    guard let sendServerMsgJsonString = ChatOutGoingEvent.message(localMessage).jsonString else {
      print(#line, "jsonString convert issue")
      return .none
    }

    state.messages.insert(localMessage, at: 0)

    return environment.websocketClient.send(
        currentUserID,
        .string(sendServerMsgJsonString)
    )
    .receive(on: environment.mainQueue)
    .eraseToEffect()
    .map(ChatAction.sendResponse)
  }
}
