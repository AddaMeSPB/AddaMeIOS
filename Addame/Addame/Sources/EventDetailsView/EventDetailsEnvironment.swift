//
//  EventDetailsEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import ConversationClient

public struct EventDetailsEnvironment {
  public init(
    conversationClient: ConversationClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.conversationClient = conversationClient
    self.mainQueue = mainQueue
  }

  public let conversationClient: ConversationClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

}
