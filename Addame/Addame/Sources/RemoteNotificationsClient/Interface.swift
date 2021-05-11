//
//  Interface.swift
//  
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import ComposableArchitecture

public struct RemoteNotificationsClient {
  public var isRegistered: () -> Bool
  public var register: () -> Effect<Never, Never>
  public var unregister: () -> Effect<Never, Never>
}

extension RemoteNotificationsClient {
  public static let noop = Self(
    isRegistered: { true },
    register: { .none },
    unregister: { .none }
  )
}
