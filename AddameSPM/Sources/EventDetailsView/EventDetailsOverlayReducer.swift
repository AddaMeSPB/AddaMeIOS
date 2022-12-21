////
////  EventDetailsOverlayReducer.swift
////
////
////  Created by Saroar Khandoker on 12.07.2021.
////
//
// import ComposableArchitecture
// import KeychainClient
// import AddaSharedModels
// import HTTPRequestKit
//
// public let eventDetailsOverlayReducer = Reducer<
//  EventDetailsOverlayState, EventDetailsOverlayAction, EventDetailsEnvironment
// > { state, action, environment in
//  switch action {
//  case .onAppear:
//
////      return environment.conversationClient.find("", state.event.conversationsId.hexString)
////      .receive(on: environment.mainQueue)
////      .catchToEffect()
////      .map(EventDetailsOverlayAction.conversationResponse)
//
//      return .none
////          .task { [state] in
////          do {
////              let conversationOutput = try await environment.conversationClient
////                  .find(state.event.conversationsId.hexString)
////
////              return EventDetailsOverlayAction.conversationResponse(.success(conversationOutput))
////          } catch {
////              return EventDetailsOverlayAction.conversationResponse(.failure(.custom("", error)))
////          }
////      }
//
//  case .alertDismissed:
//    state.alert = nil
//    return .none
//
//  case let .startChat(bool):
//    return .none
//
//  case let .askJoinRequest(bool):
//      guard let currentUSER: UserOutput = KeychainClient.readCodable(.user), //.loadCodable(for: .),
//          let conversation = state.conversation,
//          let usersId = currentUSER.id
//    else {
//        // send logs
//      return .none
//    }
//
//    let conversationId = conversation.id
//    state.isMovingChatRoom = bool
//    let adduser = AddUser(
//        conversationsId: conversationId,
//        usersId: usersId
//    )
//
////    return environment.conversationClient
////      .addUserToConversation(adduser, "\(conversationId)/users/\(usersId)")
////      .receive(on: environment.mainQueue)
////      .catchToEffect()
////      .map(EventDetailsOverlayAction.joinToEvent)
//
//      return .task {
//          do {
//              let addMe = try await environment.conversationClient.addUserToConversation(adduser)
//              return EventDetailsOverlayAction.joinToEvent(.success(addMe))
//          } catch {
//              return EventDetailsOverlayAction.joinToEvent(.failure(.custom("", error)))
//          }
//      }
//
//  case let .joinToEvent(.success(response)):
//    print(#line, response)
//    return .none
//  case let .joinToEvent(.failure(error)):
//
//    return .none
//
//  case let .conversationResponse(.success(conversationItem)):
//    state.conversation = conversationItem
//    return .none
//  case let .conversationResponse(.failure(error)):
//    state.alert = .init(title: TextState("Something went wrong please try again later"))
//    return .none
//  }
// }
