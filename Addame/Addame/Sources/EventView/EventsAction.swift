//
//  EventAction.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ChatView
import ComposableArchitecture
import ComposableCoreLocation
import EventDetailsView
import EventFormView
import Foundation
import HttpRequest
import MapKit
import SharedModels

public enum EventsAction: Equatable {
  case alertDismissed
  case dismissEventDetails

  case event(index: EventResponse.Item.ID, action: EventAction)

  case eventFormView(isNavigate: Bool)
  case eventForm(EventFormAction)

  case eventDetailsView(isPresented: Bool)
  case eventDetails(EventDetailsAction)

  case chatView(isNavigate: Bool)
  case chat(ChatAction)

  case fetchMoreEventsIfNeeded(item: EventResponse.Item?)
  case addressResponse(Result<String, Never>)

  case currentLocationButtonTapped
  case locationManager(LocationManager.Action)
  case eventsResponse(Result<EventResponse, HTTPError>)
  case eventCoordinate(Result<CLPlacemark, Never>)
  case eventTapped(EventResponse.Item)

  case popupSettings
  case dismissEvent
  case onAppear
}

public enum EventAction: Equatable {}

// swiftlint:disable:next superfluous_disable_command
extension EventsAction {
  // swiftlint:disable:next cyclomatic_complexity function_body_length superfluous_disable_command
  static func view(_ localAction: EventView.ViewAction) -> Self {
    switch localAction {
    case .alertDismissed:
      return .alertDismissed
    case .dismissEventDetails:
      return .dismissEventDetails
    case let .eventFormView(active):
      return .eventFormView(isNavigate: active)
    case let .eventForm(eventFormAction):
      return eventForm(eventFormAction)
    case let .chatView(isNavigate: bool):
      return .chatView(isNavigate: bool)
    case let .chat(action):
      return .chat(action)
    case let .event(index: index, action: action):
      return .event(index: index, action: action)
    case .currentLocationButtonTapped:
      return .currentLocationButtonTapped
    case let .eventTapped(event):
      return eventTapped(event)
    case .popupSettings:
      return popupSettings
    case .dismissEvent:
      return .dismissEvent
    case .onAppear:
      return .onAppear
    case let .eventDetailsView(isPresented: isPresented):
      return .eventDetailsView(isPresented: isPresented)
    case let .eventDetails(action):
      return .eventDetails(action)
    case let .fetchMoreEventsIfNeeded(item: item):
      return .fetchMoreEventsIfNeeded(item: item)
    }
  }
}
