//
//  ChatEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import Combine
import ComposableArchitecture
import ChatClient
import ConversationClient
import WebsocketClient
import SharedModels

public struct ChatEnvironment {

  let chatClient: ChatClient
  let websocket: WebsocketEnvironment
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    chatClient: ChatClient,
    websocket: WebsocketEnvironment,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.chatClient = chatClient
    self.websocket = websocket
    self.mainQueue = mainQueue
  }

}

public class WebsocketEnvironment {

  let websocketClient: WebsocketClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    websocketClient: WebsocketClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.websocketClient = websocketClient
    self.websocketClient.handshake()
    self.mainQueue = mainQueue
  }

  public func send(_ msg: SocketMessage) {
    self.websocketClient.send(msg.localMsg, msg.remostJSON)
  }

}

public struct SocketMessage: Equatable {
  public var localMsg: ChatMessageResponse.Item
  public var remostJSON: String

  public static func == (lhs: SocketMessage, rhs: SocketMessage) -> Bool {
      return lhs.localMsg == rhs.localMsg && lhs.remostJSON == rhs.remostJSON
  }
}
