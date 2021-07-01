//
//  TabsEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 04.06.2021.
//

import Combine
import ComposableArchitecture
import WebSocketClient
import HttpRequest
import InfoPlist
import KeychainService
import SharedModels

public struct TabsEnvironment {

  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public let webSocketClient: WebSocketClient

  public init(
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    webSocketClient: WebSocketClient
  ) {
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.webSocketClient = webSocketClient
  }

  public func getAccessToken() -> AnyPublisher<String, HTTPError> {
    guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
      assertionFailure("not Authorized Token are missing")
      return Fail(error: HTTPError.missingTokenFromIOS )
        .eraseToAnyPublisher()
    }

    return Just(token.accessToken)
      .setFailureType(to: HTTPError.self)
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
