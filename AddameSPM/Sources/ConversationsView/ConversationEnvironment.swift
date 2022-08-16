//
//  ConversationEnvironment.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import ChatClient
import Combine
import ComposableArchitecture
import ConversationClient
import ConversationClientLive
import AddaSharedModels
import WebSocketClient
import Foundation

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

extension ConversationEnvironment {
  public static let live: ConversationEnvironment = .init(
    conversationClient: .live,
    websocketClient: .live,
    backgroundQueue: .main,
    mainQueue: .main
  )
}
