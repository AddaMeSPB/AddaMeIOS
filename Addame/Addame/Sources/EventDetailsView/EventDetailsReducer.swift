//
//  EventDetailsReducer.swift
//
//
//  Created by Saroar Khandoker on 05.07.2021.
//

import ChatView
import ComposableArchitecture
import ConversationClient
import ConversationClientLive
import HttpRequest
import KeychainService
import MapKit
import MapView
import SharedModels
import SwiftUI

public let eventDetailsReducer = Reducer<
  EventDetailsState, EventDetailsAction, EventDetailsEnvironment
>.combine(
  eventDetailsOverlayReducer
    .pullback(
      state: \.eventDetailsOverlayState,
      action: /EventDetailsAction.eventDetailsOverlay,
      environment: {
        EventDetailsEnvironment(
          conversationClient: ConversationClient.live(api: .build),
          mainQueue: $0.mainQueue
        )
      }
    ),
  Reducer { state, action, _ in

    switch action {
    case .onAppear:

      let coordinate = CLLocationCoordinate2D(
        latitude: state.event.coordinate.latitude,
        longitude: state.event.coordinate.longitude
      )

      state.region = CoordinateRegion(
        center: coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
      )

      state.pointsOfInterest = [
        .init(coordinate: coordinate, subtitle: state.event.addressName, title: state.event.name)
      ]

      return .none

    case .alertDismissed:
      return .none
    case let .moveToChatRoom(bool):
      return .none
    case let .updateRegion(coordinateRegion):
      return .none
    case let .eventDetailsOverlay(action):
      switch action {
      case .onAppear:
        return .none
      case .alertDismissed:
        return .none
      case .startChat:
        return .none
      case .askJoinRequest:
        return .none
      case .joinToEvent:
        return .none
      case let .conversationResponse(.success(conversationItem)):

        guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
          return .none
        }

        state.conversation = conversationItem
        state.chatMembers = conversationItem.members?.count ?? 0

        state.eventDetailsOverlayState.isMember =
          conversationItem.members?.contains(
            where: { $0.id == currentUSER.id }
          ) ?? false

        state.eventDetailsOverlayState.isAdmin =
          conversationItem.admins?.contains(
            where: { $0.id == currentUSER.id }
          ) ?? false

        return .none

      case let .conversationResponse(.failure(error)):
        return .none
      }
    }
  }
)
