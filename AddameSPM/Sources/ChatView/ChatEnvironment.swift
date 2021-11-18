//
//  ChatEnvironment.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import ChatClient
import ChatClientLive
import Combine
import ComposableArchitecture
import ConversationClient
import KeychainService
import SharedModels
import WebSocketClient
import WebSocketClientLive

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

extension ChatEnvironment {
  public static let live: ChatEnvironment = .init(
    chatClient: .live(api: .build),
    websocketClient: .live,
    mainQueue: .main,
    backgroundQueue: .main
  )
}
