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
import WebsocketClient
import SharedModels

public struct ConversationEnvironment {

  let conversationClient: ConversationClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    conversationClient: ConversationClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.backgroundQueue = backgroundQueue
    self.conversationClient = conversationClient
    self.mainQueue = mainQueue
  }

}

// public class WebsocketEnvironment {
//    
//  let websocketClient: WebsocketClient
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//  
//  public init(
//    websocketClient: WebsocketClient,
//    mainQueue: AnySchedulerOf<DispatchQueue>
//  ) {
//    self.websocketClient = websocketClient
//    self.websocketClient.handshake()
//    self.mainQueue = mainQueue
//  }
//  
// }