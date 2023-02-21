//
//  TabsEnvironment.swift
//
//
//  Created by Saroar Khandoker on 04.06.2021.
//

import Combine
import ComposableArchitecture

import InfoPlist
import KeychainClient
import AddaSharedModels

import DeviceClient
import Foundation

// public struct TabsEnvironment {
//  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//  public let webSocketClient: WebSocketClient
//  public var deviceClient: DeviceClient
//
//  public init(
//    backgroundQueue: AnySchedulerOf<DispatchQueue>,
//    mainQueue: AnySchedulerOf<DispatchQueue>,
//    webSocketClient: WebSocketClient,
//    devicClient: DeviceClient
//  ) {
//    self.backgroundQueue = backgroundQueue
//    self.mainQueue = mainQueue
//    self.webSocketClient = webSocketClient
//    self.deviceClient = devicClient
//  }
//
//  public func getAccessToken() -> AnyPublisher<String, HTTPRequest.HRError> {
//    guard let token: RefreshTokenResponse = KeychainService.loadCodable(for: .token) else {
//      return Fail(error: HTTPRequest.HRError.missingTokenFromIOS)
//        .eraseToAnyPublisher()
//    }
//
//    return Just(token.accessToken)
//      .setFailureType(to: HTTPRequest.HRError.self)
//      .eraseToAnyPublisher()
//  }
//
//  public var currentUser: UserOutput {
//    guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
//      assertionFailure("current user is missing")
//      return UserOutput.withFirstName
//    }
//
//    return currentUSER
//  }
// }
//
// extension TabsEnvironment {
//  public static let live: TabsEnvironment = .init(
//    backgroundQueue: .main,
//    mainQueue: .main,
//    webSocketClient: .live,
//    devicClient: .live
//  )
// }
