//
//  EventDetailsOverlayReducer.swift
//  
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import SharedModels
import KeychainService

public let eventDetailsOverlayReducer = Reducer<
  EventDetailsOverlayState, EventDetailsOverlayAction, EventDetailsEnvironment
> { state, action, environment in
  switch action {

  case .onAppear:

    return environment.conversationClient.find("", state.event.conversationsId)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EventDetailsOverlayAction.conversationResponse)

  case .alertDismissed:
    state.alert = nil
    return .none

  case let .startChat(bool):
    return .none

  case let .askJoinRequest(bool):
    guard let currentUSER: User = KeychainService.loadCodable(for: .user),
          let conversation = state.conversation
    else {
      return .none
    }

    state.isMovingChatRoom = bool
    let adduser = AddUser(
      conversationsId: conversation.id,
      usersId: currentUSER.id
    )

    return environment.conversationClient
      .addUserToConversation(adduser, "\(conversation.id)/users/\(currentUSER.id)")
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EventDetailsOverlayAction.joinToEvent)

  case let .joinToEvent(.success(response)):
    print(#line, response)
    return .none
  case let .joinToEvent(.failure(error)):

    return .none

  case let .conversationResponse(.success(conversationItem)):
    state.conversation = conversationItem
    return .none
  case let .conversationResponse(.failure(error)):
    state.alert = .init(title: TextState("Something went wrong please try again later") )
    return .none
  }
}
