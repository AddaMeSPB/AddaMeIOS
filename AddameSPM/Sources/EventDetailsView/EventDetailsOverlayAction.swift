//
//  EventDetailsOverlayAction.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import ConversationClient
import HTTPRequestKit
import KeychainClient
import MapView
import AddaSharedModels

public enum EventDetailsOverlayAction: Equatable {
    public static func == (lhs: EventDetailsOverlayAction, rhs: EventDetailsOverlayAction) -> Bool {
        return true
    }

  case onAppear
  case alertDismissed
  case startChat(Bool)
  case askJoinRequest(Bool)
  case joinToEvent(Result<AddUser, HTTPRequest.HRError>)
  case conversationResponse(Result<ConversationOutPut, HTTPRequest.HRError>)
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
