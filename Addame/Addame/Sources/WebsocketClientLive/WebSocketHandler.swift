//
//  WebsocketHandler.swift
//  
//
//  Created by Saroar Khandoker on 18.06.2021.
//

// import Combine
// import ComposableArchitecture
// import SwiftUI
// import HttpRequest
// import SharedModels
// import KeychainService
// import InfoPlist
// import WebSocketClient
//
// struct WebSocketState: Equatable {
//  var alert: AlertState<WebSocketAction>?
//  var connectivityState = ConnectivityState.disconnected
//  var messageToSend = ""
//  var conversation: ConversationResponse.Item?
//  var message: ChatMessageResponse.Item?
//  var receivedMessages: WebSocketClient.Message?
//
//  enum ConnectivityState: String {
//    case connected
//    case connecting
//    case disconnected
//  }
// }
//
// enum WebSocketAction: Equatable {
//  case alertDismissed
//  case connectButtonTapped
//  case messageToSendChanged(String)
//  case pingResponse(NSError?)
//  case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
//  case sendButtonTapped
//  case sendResponse(NSError?)
//  case webSocket(WebSocketClient.Action)
// }
//
// struct WebSocketEnvironment {
//  var mainQueue: AnySchedulerOf<DispatchQueue>
//  var webSocket: WebSocketClient
// }
//
// let webSocketReducer = Reducer<WebSocketState, WebSocketAction, WebSocketEnvironment> {
//  state, action, environment in
//  struct WebSocketId: Hashable {}
//
//  var receiveSocketMessageEffect: Effect<WebSocketAction, Never> {
//    return environment.webSocket.receive(WebSocketId())
//      .receive(on: environment.mainQueue)
//      .catchToEffect()
//      .map(WebSocketAction.receivedSocketMessage)
//      .cancellable(id: WebSocketId())
//  }
//
//  var sendPingEffect: Effect<WebSocketAction, Never> {
//    return environment.webSocket.sendPing(WebSocketId())
//      .delay(for: 10, scheduler: environment.mainQueue)
//      .map(WebSocketAction.pingResponse)
//      .eraseToEffect()
//      .cancellable(id: WebSocketId())
//  }
//
//  switch action {
//  case .alertDismissed:
//    state.alert = nil
//    return .none
//
//  case .connectButtonTapped:
//    switch state.connectivityState {
//    case .connected, .connecting:
//      state.connectivityState = .disconnected
//      return .cancel(id: WebSocketId())
//
//    case .disconnected:
//      var baseURL: URL { EnvironmentKeys.webSocketURL }
//      state.connectivityState = .connecting
//      // here run auth token when get result action 
//      return environment.webSocket.open(WebSocketId(), baseURL, "", [])
//        .receive(on: environment.mainQueue)
//        .map(WebSocketAction.webSocket)
//        .eraseToEffect()
//        .cancellable(id: WebSocketId())
//    }
//
//  case let .messageToSendChanged(message):
//    state.messageToSend = message
//    return .none
//
//  case .pingResponse:
//    // Ping the socket again in 10 seconds
//    return sendPingEffect
//
//  case let .receivedSocketMessage(.success(.string(string))):
//
//    let chatOutGoingEvent = ChatOutGoingEvent.from(json: string, using: .utf8)
//
//    // Immediately ask for the next socket message
//    return receiveSocketMessageEffect
//
//  case let .receivedSocketMessage(.success(.data(data))):
//    let handleData = ChatOutGoingEvent.decode(data: data)
//    switch handleData {
//    case .connect(_):
//      break
//    case .disconnect(_):
//      break
//    case .conversation(let message):
//      print(#line, message)
//      state.conversation?.lastMessage = message
//    case .message(let message):
//      print(#line, message)
//      state.message = message
//      self.handleMessageResponse(message)
//    case .notice(let msg):
//      print(#line, msg)
//    case .error(let error):
//      print(#line, error)
//    case .none:
//      print(#line, "decode error")
//    }
//
//    // Immediately ask for the next socket message
//    return receiveSocketMessageEffect
//
//  case .receivedSocketMessage(.success):
//    // Immediately ask for the next socket message
//    return receiveSocketMessageEffect
//
//  case .receivedSocketMessage(.failure):
//    return .none
//
//  case .sendButtonTapped:
//    let messageToSend = state.messageToSend
//    state.messageToSend = ""
//
//    return environment.webSocket.send(WebSocketId(), .string(messageToSend))
//      .eraseToEffect()
//      .map(WebSocketAction.sendResponse)
//
//  case let .sendResponse(error):
//    if error != nil {
//      state.alert = .init(title: .init("Could not send socket message. Try again."))
//    }
//    return .none
//
//  case let .webSocket(.didClose(code, _)):
//    state.connectivityState = .disconnected
//    return .cancel(id: WebSocketId())
//
//  case let .webSocket(.didBecomeInvalidWithError(error)),
//    let .webSocket(.didCompleteWithError(error)):
//    state.connectivityState = .disconnected
//    if error != nil {
//      state.alert = .init(title: .init("Disconnected from socket for some reason. Try again."))
//    }
//    return .cancel(id: WebSocketId())
//
//  case .webSocket(.didOpenWithProtocol):
//    state.connectivityState = .connected
//    return .merge(
//      receiveSocketMessageEffect,
//      sendPingEffect
//    )
//  }
// }
