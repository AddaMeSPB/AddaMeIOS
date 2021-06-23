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
import WebSocketClient
import SharedModels

public struct ChatEnvironment {

  let chatClient: ChatClient
  public let websocketClient: WebSocketClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    chatClient: ChatClient,
    websocketClient: WebSocketClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.chatClient = chatClient
    self.websocketClient = websocketClient
    self.mainQueue = mainQueue
  }

}

public struct SocketMessage: Equatable {
  public var localMsg: ChatMessageResponse.Item
  public var remostJSON: String

  public static func == (lhs: SocketMessage, rhs: SocketMessage) -> Bool {
      return lhs.localMsg == rhs.localMsg && lhs.remostJSON == rhs.remostJSON
  }
}
