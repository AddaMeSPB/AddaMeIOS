//
//  EventDetailsAction.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import ConversationClient
import HTTPRequestKit
import KeychainService
import MapView
import AddaSharedModels

public enum EventDetailsAction: Equatable {
  case onAppear
  case alertDismissed
  case moveToChatRoom(Bool)
  case updateRegion(CoordinateRegion?)
  case eventDetailsOverlay(EventDetailsOverlayAction)
}

extension EventDetailsAction {
  static func view(_ localAction: EventDetailsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case let .moveToChatRoom(bool):
      return .moveToChatRoom(bool)
    case let .updateRegion(coordinateRegion):
      return .updateRegion(coordinateRegion)
    case let .eventDetailsOverlay(action):
      return .eventDetailsOverlay(action)
    }
  }
}
