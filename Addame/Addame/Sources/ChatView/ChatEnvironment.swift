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
import KeychainService

public struct ChatEnvironment {

  let chatClient: ChatClient
  public let websocketClient: WebSocketClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>

  public init(
    chatClient: ChatClient,
    websocketClient: WebSocketClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.chatClient = chatClient
    self.websocketClient = websocketClient
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
  }

  public var currentUser: User {
    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
      assertionFailure("current user is missing")
      return User.draff
    }

    return currentUSER
  }
}
