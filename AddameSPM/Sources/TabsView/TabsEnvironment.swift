//
//  TabsEnvironment.swift
//
//
//  Created by Saroar Khandoker on 04.06.2021.
//

import Combine
import ComposableArchitecture
import HTTPRequestKit
import InfoPlist
import KeychainService
import SharedModels
import WebSocketClient
import DeviceClient

public struct TabsEnvironment {
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public let webSocketClient: WebSocketClient
  public var deviceClient: DeviceClient

  public init(
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    webSocketClient: WebSocketClient,
    devicClient: DeviceClient
  ) {
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.webSocketClient = webSocketClient
    self.deviceClient = devicClient
  }

  public func getAccessToken() -> AnyPublisher<String, HTTPRequest.HRError> {
    guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
      return Fail(error: HTTPRequest.HRError.missingTokenFromIOS)
        .eraseToAnyPublisher()
    }

    return Just(token.accessToken)
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
  }

  public var currentUser: User {
    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
      assertionFailure("current user is missing")
      return User.draff
    }

    return currentUSER
  }
}

extension TabsEnvironment {
  public static let live: TabsEnvironment = .init(
    backgroundQueue: .main,
    mainQueue: .main,
    webSocketClient: .live,
    devicClient: .live(api: .build)
  )
}
