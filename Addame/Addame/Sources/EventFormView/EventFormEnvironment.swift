//
//  EventFormEnvironment.swift
//  EventFormEnvironment
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import ComposableArchitecture

import EventClient
import KeychainService
import SharedModels

public struct EventFormEnvironment {

  public var eventClient: EventClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    eventClient: EventClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.eventClient = eventClient
    self.mainQueue = mainQueue
  }

  public var currentUser: User {
    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
      assertionFailure("current user is missing")
      return User.draff
    }

    return currentUSER
  }

}