//
//  ChatReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import SharedModels
import KeychainService
import InfoPlist
import FoundationExtension

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment> { state, action, environment in

  var fetchMoreMessages: Effect<ChatAction, Never> {

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

  var receiveSocketMessageEffect: Effect<ChatAction, Never> {
    return environment.websocketClient.receive(WebSocketId())
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ChatAction.receivedSocketMessage)
      .cancellable(id: WebSocketId())
  }

  var sendPingEffect: Effect<ChatAction, Never> {
    return environment.websocketClient.sendPing(WebSocketId())
      .receive(on: environment.mainQueue)
      .delay(for: 10, scheduler: environment.mainQueue)
      .map(ChatAction.pingResponse)
      .eraseToEffect()
      .cancellable(id: WebSocketId())
  }

  struct WebSocketId: Hashable {}

  switch action {

  case .onAppear:
    return fetchMoreMessages

  case .alertDismissed:
    state.alert = nil
    return .none

  case .conversation(let converstion):
    state.conversation = converstion
    return fetchMoreMessages

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
      return fetchMoreMessages
    }

    let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -10)
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
    return .cancel(id: WebSocketId())

  case let .webSocket(.didBecomeInvalidWithError(error)),
    let .webSocket(.didCompleteWithError(error)):
    // state.connectivityState = .disconnected
    if error != nil {
      state.alert = .init(title: .init("Disconnected from socket for some reason. Try again."))
    }
    return .cancel(id: WebSocketId())

  case .webSocket(.didOpenWithProtocol):
    // state.connectivityState = .connected
    return .merge(
      receiveSocketMessageEffect,
      sendPingEffect
    )

  case .pingResponse:
    // Ping the socket again in 10 seconds
    return sendPingEffect

  case .receivedSocketMessage(.success(.data(let data))):

    let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)

    switch chatOutGoingEvent {
    case .connect(_):
      break
    case .disconnect(_):
      break
    case .conversation(let message):
      break
    case .message(let message):
      state.messages.append(message)
      return .none
    case .notice(let msg):
      break
    case .error(let error):
      print(#line, error)
    case .none:
      print(#line, "decode error")
      return .none
    }

    return .none

  case .receivedSocketMessage(.failure):
    return .none

  case let .messageToSendChanged(message):
    state.messageToSend = message

    return .none

  case .sendButtonTapped:
    let composedMessage = state.messageToSend
    state.messageToSend = ""

    guard
      let currentUSER: User = KeychainService.loadCodable(for: .user),
      let conversationsID = state.conversation?.id
    else {
      print(#line, "current user or conversation id missing")
      return .none
    }

    let localMessage = ChatMessageResponse.Item(
      id: ObjectIdGenerator.shared.generate(), conversationId: conversationsID,
      messageBody: composedMessage, sender: currentUSER, recipient: nil,
      messageType: .text, isRead: false,
      isDelivered: false, createdAt: nil, updatedAt: nil
    )

    guard let sendServerMsgJsonString = ChatOutGoingEvent.message(localMessage).jsonString else {
      print(#line, "json convert issue")
      return .none
    }

    state.messages.append(localMessage)

    return environment.websocketClient.send(
      WebSocketId(), .string(sendServerMsgJsonString)
    )
    .eraseToEffect()
    .map(ChatAction.sendResponse)

  case .receivedSocketMessage(.success(.string(_))):

    return .none
  }
}
