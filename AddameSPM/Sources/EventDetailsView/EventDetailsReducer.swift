//
//  EventDetailsReducer.swift
//
//
//  Created by Saroar Khandoker on 05.07.2021.
//

// import ChatView
// import ComposableArchitecture
// import ConversationClient
// import ConversationClientLive
// import HTTPRequestKit
// import KeychainClient
// import MapKit
// import MapView
// import AddaSharedModels
// import SwiftUI
//
// public let eventDetailsReducer = Reducer<
//  EventDetailsState, EventDetailsAction, EventDetailsEnvironment
// >.combine(
//  eventDetailsOverlayReducer
//    .pullback(
//      state: \.eventDetailsOverlayState,
//      action: /EventDetailsAction.eventDetailsOverlay,
//      environment: {
//        EventDetailsEnvironment(
//          conversationClient: .live,
//          mainQueue: $0.mainQueue
//        )
//      }
//    ),
//  Reducer { state, action, _ in
//
//    switch action {
//    case .onAppear:
//
//      let latitude = state.event.coordinates[0]
//      let longitude = state.event.coordinates[1]
//
//      let coordinate = CLLocationCoordinate2D(
//        latitude: latitude,
//        longitude: longitude
//      )
//
//      state.region = CoordinateRegion(
//        center: coordinate,
//        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
//      )
//
//      state.pointsOfInterest = [
//        .init(coordinate: coordinate, subtitle: state.event.addressName, title: state.event.name)
//      ]
//
//      return .none
//
//    case .alertDismissed:
//      return .none
//    case let .moveToChatRoom(bool):
//      return .none
//    case let .updateRegion(coordinateRegion):
//      return .none
//    case let .eventDetailsOverlay(action):
//      switch action {
//      case .onAppear:
//        return .none
//      case .alertDismissed:
//        return .none
//      case .startChat:
//        return .none
//      case .askJoinRequest:
//        return .none
//      case .joinToEvent:
//        return .none
//      case let .conversationResponse(.success(conversationItem)):
//
//        state.conversation = conversationItem
//
//        if let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) {
//            if let members = conversationItem.members {
//                state.chatMembers = members.count
//                state.eventDetailsOverlayState.isMember = members.contains(where: { $0.id == currentUSER.id })
//            }
//
//            if let admins = conversationItem.admins {
//                state.eventDetailsOverlayState.isAdmin = admins.contains(where: { $0.id == currentUSER.id })
//            }
//        }
//
//        return .none
//
//      case let .conversationResponse(.failure(error)):
//        return .none
//      }
//    }
//  }
// )
