// public let eventDetailsOverlayReducer = Reducer<
//  HangoutDetailsOverlayState, HangoutDetailsOverlayAction, HangoutDetailsEnvironment
// > { state, action, environment in
//  switch action {
//  case .onAppear:
//
////      return environment.conversationClient.find("", state.event.conversationsId.hexString)
////      .receive(on: environment.mainQueue)
////      .catchToEffect()
////      .map(HangoutDetailsOverlayAction.conversationResponse)
//
//      return .none
////          .task { [state] in
////          do {
////              let conversationOutput = try await environment.conversationClient
////                  .find(state.event.conversationsId.hexString)
////
////              return HangoutDetailsOverlayAction.conversationResponse(.success(conversationOutput))
////          } catch {
////              return HangoutDetailsOverlayAction.conversationResponse(.failure(.custom("", error)))
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
////      .map(HangoutDetailsOverlayAction.joinToEvent)
//
//      return .task {
//          do {
//              let addMe = try await environment.conversationClient.addUserToConversation(adduser)
//              return HangoutDetailsOverlayAction.joinToEvent(.success(addMe))
//          } catch {
//              return HangoutDetailsOverlayAction.joinToEvent(.failure(.custom("", error)))
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
