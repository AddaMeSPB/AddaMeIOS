//
//  EventDetailsEnvironment.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import ConversationClient
import ConversationClientLive
import Foundation

public struct EventDetailsEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.mainQueue = mainQueue
  }

  var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension EventDetailsEnvironment {
  public static let live: EventDetailsEnvironment = .init(
    mainQueue: .main
  )
}
