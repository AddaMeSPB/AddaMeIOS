//
//  ChatReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import FoundationExtension
import InfoPlist
import KeychainService
import SharedModels

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment> {
  state, action, environment in

  var fetchMoreMessages: Effect<ChatAction, Never> {
    guard let conversationsID = state.conversation?.id else {
      print(#line, "Conversation id missing")
      return .none
    }

    let query = QueryItem(page: "\(state.currentPage)", per: "10")

    return environment.chatClient
      .messages(query, conversationsID, "/by/conversations/\(conversationsID)")
      .retry(3)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ChatAction.messages)
  }

  var receiveSocketMessageEffect: Effect<ChatAction, Never> {
    return environment.websocketClient.receive(environment.currentUser.id)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ChatAction.receivedSocketMessage)
      .cancellable(id: environment.currentUser.id)
  }

  var sendPingEffect: Effect<ChatAction, Never> {
    return environment.websocketClient.sendPing(environment.currentUser.id)
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue)
      .delay(for: 10, scheduler: environment.mainQueue)
      .map(ChatAction.pingResponse)
      .eraseToEffect()
      .cancellable(id: environment.currentUser.id)
  }

  switch action {
  case .onAppear:

    return fetchMoreMessages

  case .alertDismissed:
    state.alert = nil
    return .none

  case let .conversation(converstion):
    state.conversation = converstion
    return fetchMoreMessages

  case let .messages(.success(response)):
    state.canLoadMorePages = state.messages.count < response.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

//    response.items.forEach {
//      if !state.messages.contains($0) {
//        state.messages.append($0)
//      }
//    }

    let combineMessageResults = (response.items + state.messages).uniqElemets().sorted()
    state.messages = .init(uniqueElements: combineMessageResults)

    return .none

  case let .messages(.failure(error)):
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
    return .none

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

    let localMessage = ChatMessageResponse.Item(
      id: ObjectIdGenerator.shared.generate(), conversationId: conversationsID,
      messageBody: composedMessage, sender: environment.currentUser, recipient: nil,
      messageType: .text, isRead: false,
      isDelivered: false, createdAt: nil, updatedAt: nil
    )

    guard let sendServerMsgJsonString = ChatOutGoingEvent.message(localMessage).jsonString else {
      print(#line, "json convert issue")
      return .none
    }

    state.messages.insert(localMessage, at: 0)

    return environment.websocketClient.send(
      environment.currentUser.id, .string(sendServerMsgJsonString)
    )
    .receive(on: environment.mainQueue)
    .eraseToEffect()
    .map(ChatAction.sendResponse)
  }
}
