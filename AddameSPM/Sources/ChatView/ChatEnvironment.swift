////
////  ChatEnvironment.swift
////
////
////  Created by Saroar Khandoker on 19.04.2021.
////
//import Combine
//import ComposableArchitecture
//
//import KeychainClient
//import AddaSharedModels

//import Foundation
//
//public struct ChatEnvironment {
//  public let websocketClient: WebSocketClient
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
//
//  public init(
//    websocketClient: WebSocketClient,
//    mainQueue: AnySchedulerOf<DispatchQueue>,
//    backgroundQueue: AnySchedulerOf<DispatchQueue>
//  ) {
//    self.websocketClient = websocketClient
//    self.mainQueue = mainQueue
//    self.backgroundQueue = backgroundQueue
//  }
//
//  public var currentUser: UserOutput {
//      return UserOutput.withFirstName
//  }
//}
//
//extension ChatEnvironment {
//  public static let live: ChatEnvironment = .init(
//    websocketClient: .live,
//    mainQueue: .main,
//    backgroundQueue: .main
//  )
//}
