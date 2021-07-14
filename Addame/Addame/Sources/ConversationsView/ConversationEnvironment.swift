//
//  ConversationEnvironment.swift
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

public struct ConversationEnvironment {

  public let conversationClient: ConversationClient
  public let websocketClient: WebSocketClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    conversationClient: ConversationClient,
    websocketClient: WebSocketClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.backgroundQueue = backgroundQueue
    self.conversationClient = conversationClient
    self.websocketClient = websocketClient
    self.mainQueue = mainQueue
  }

}

// public class WebsocketEnvironment {
//    
//  let websocketClient: WebSocketClient
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//  
//  public init(
//    websocketClient: WebSocketClient,
//    mainQueue: AnySchedulerOf<DispatchQueue>
//  ) {
//    self.websocketClient = websocketClient
//    self.websocketClient.handshake()
//    self.mainQueue = mainQueue
//  }
//  
// }
