//
//  EventDetailsOverlayAction.swift
//  
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture

import MapView
import SharedModels
import HttpRequest
import ConversationClient
import KeychainService

public enum EventDetailsOverlayAction: Equatable {
  case onAppear
  case alertDismissed
  case startChat(Bool)
  case askJoinRequest(Bool)
  case joinToEvent(Result<ConversationResponse.UserAdd, HTTPError>)
  case conversationResponse(Result<ConversationResponse.Item, HTTPError>)
}

extension EventDetailsOverlayAction {
  static func view(_ localAction: EventDetailsOverlayView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case let .startChat(bool):
      return .startChat(bool)
    case let .askJoinRequest(bool):
      return .askJoinRequest(bool)
    case let .joinToEvent(response):
      return .joinToEvent(response)
    case let .conversationResponse(res):
      return .conversationResponse(res)
    }
  }
}
