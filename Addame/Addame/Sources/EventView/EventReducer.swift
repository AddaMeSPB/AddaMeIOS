//
//  EventReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SwiftUI
import MapKit
import Combine

import ComposableArchitecture

import SharedModels
import HttpRequest

import EventFormView
import EventDetailsView

import ChatView
import ChatClient
import ChatClientLive

import WebSocketClient
import WebSocketClientLive

import ConversationClient
import ConversationClientLive

struct Foo {
  @AppStorage("isAuthorized")
  public static var isAuthorized: Bool = false
}

public let eventReducer = Reducer<EventsState, EventsAction, EventsEnvironment> { state, action, environment in
  struct LocationManagerId: Hashable {}

  func fetchMoreEventIfNeeded() -> Effect<EventsAction, Never> {
    guard state.isConnected, let location = state.location else { return .none }
    state.location = location
    //      self.fetchMoreEventIfNeeded()
    //      self.fetchAddress(location)

    let distance = UserDefaults.standard.double(forKey: "distance") == 0.0
      ? 250.0
      : UserDefaults.standard.double(forKey: "distance")

    let lat = "\(location.coordinate.latitude)"
    let long = "\(location.coordinate.longitude)"

    guard !state.isLoadingPage && state.canLoadMorePages else { return .none }

    state.isLoadingPage = true

    let query = QueryItem(page: "\(state.currentPage)", per: "10", lat: lat, long: long, distance: "\(Int(distance))" )

    return environment.eventClient.events(query, "")
      .retry(3)
      .receive(on: environment.mainQueue.animation(.default))
      .removeDuplicates()
      .catchToEffect()
      .map(EventsAction.eventsResponse)
  }

  func fetchMoreMyEvents() -> Effect<EventsAction, Never> {

    guard !state.isLoadingPage && state.canLoadMorePages else { return .none }

    state.isLoadingPage = true

    let query = QueryItem(page: "\(state.currentPage)", per: "10")

    return environment.eventClient.events(query, "my")
      .retry(3)
      .receive(on: environment.mainQueue.animation(.default))
      .removeDuplicates()
      .catchToEffect()
      .map(EventsAction.myEventsResponse)
  }

  func presentChatView() -> Effect<EventsAction, Never> {
    state.eventDetailsState = nil
    state.chatState = nil
    return Effect(value: EventsAction.chatView(isNavigate: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()
  }

  switch action {

  case let .eventFormView(isNavigate: active):
    state.eventFormState = active ? EventFormState() : nil
    return .none

  case .dismissEvent:

    return .none

  case .onAppear:

    return .merge(
      environment.locationManager
        .create(id: LocationManagerId())
        .map(EventsAction.locationManager),

      environment.locationManager
        .requestWhenInUseAuthorization(id: LocationManagerId())
        .fireAndForget()
    )

  case .alertDismissed:
    state.alert = nil
    return .none

  case .fetchMoreEventIfNeeded(let item):

    guard let item = item else {
      return fetchMoreEventIfNeeded()
    }

    let threshouldIndex = state.events.index(state.events.endIndex, offsetBy: -7)
    if state.events.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchMoreEventIfNeeded()
    }

    return .none

  case .fetchMyEvents:
    // move inside .locationManager(.didUpdateLocations(locations)):
    return fetchMoreMyEvents()

  case .event(index: let index):

    return .none
  case .eventsResponse(.success(let eventArray)):

    state.waitingForUpdateLocation = false
    state.canLoadMorePages = state.events.count < eventArray.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    state.events = (state.events + eventArray.items)
    return .none

  case .eventsResponse(.failure(let error)):
    state.isLoadingPage = false
    state.alert = .init(title: TextState(error.description))

    return .none

  case .myEventsResponse(.success(let events)):

    state.waitingForUpdateLocation = false
    state.canLoadMorePages = state.events.count < events.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    state.myEvents = (state.myEvents + events.items)

    return.none

  case .myEventsResponse(.failure(let error)):

    state.alert = .init(
      title: TextState("fetch my event error")
    )

    return .none

  case .eventTapped(let event):
    state.event = event
    return Effect(value: EventsAction.eventDetailsView(isPresented: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()

  case let .fetachAddressFromCLLocation(cllocation):
    return .none

  case .addressResponse(.success(let address)):
    return .none

  case .locationManager(.didChangeAuthorization(.authorizedAlways)),
       .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):

    state.isLocationAuthorized = true
    state.isConnected = true

    return environment.locationManager
      .requestLocation(id: LocationManagerId())
      .fireAndForget()

  case .locationManager(.didChangeAuthorization(.denied)),
       .locationManager(.didChangeAuthorization(.restricted)):

    state.isLocationAuthorized = false
    state.isConnected = false

    state.alert = .init(
      title: TextState("Please give us access to your location so you can use our full features"),
      message: TextState("Please go to Settings and turn on the permissions"),
      primaryButton: .cancel(TextState("Cancel"), send: .alertDismissed),
      secondaryButton: .default(TextState("Go Settings"), send: .popupSettings)
    )

    return .none

  case let .locationManager(.didUpdateLocations(locations)):
    print(#line, locations)
    guard state.isConnected, let location = locations.first else { return .none }
    state.location = location
    //      self.fetchMoreEventIfNeeded()
    //      self.fetchAddress(location)

    return fetchMoreEventIfNeeded()

  case .locationManager(.didChangeAuthorization(.notDetermined)):
    return .none
  case .locationManager(.didChangeAuthorization( let status)):
    print(#line, status)
    return .none
  case .locationManager(.didDetermineState(_, region: let region)):
    return .none
  case .locationManager(.didEnterRegion(_)):
    return .none
  case .locationManager(.didExitRegion(_)):
    return .none
  case let .locationManager(.didFailRanging(beaconConstraint: beaconConstraint, error: error)):
    return .none
  case .locationManager(.didFailWithError(_)):
    return .none
  case .locationManager(.didFinishDeferredUpdatesWithError(_)):
    return .none
  case .locationManager(.didPauseLocationUpdates):
    return .none
  case .locationManager(.didResumeLocationUpdates):
    return .none
  case .locationManager(.didStartMonitoring(region: let region)):
    return .none
  case .locationManager(.didUpdateHeading(newHeading: let newHeading)):
    return .none
  case let .locationManager(.didUpdateTo(newLocation: newLocation, oldLocation: oldLocation)):
    return .none
  case .locationManager(.didVisit(_)):
    return .none
  case let .locationManager(.monitoringDidFail(region: region, error: error)):
    return .none
  case .locationManager(.didRangeBeacons(_, satisfyingConstraint: let satisfyingConstraint)):
    return .none
  case .currentLocationButtonTapped:

    guard environment.locationManager.locationServicesEnabled() else {
      state.alert = .init(title: TextState("Location services are turned off."))
      state.waitingForUpdateLocation = false
      return .none
    }

    switch environment.locationManager.authorizationStatus() {
    case .notDetermined:
      state.isRequestingCurrentLocation = true
      state.waitingForUpdateLocation = false
      #if os(macOS)
      return environment.locationManager
        .requestAlwaysAuthorization(id: LocationManagerId())
        .fireAndForget()
      #else
      return environment.locationManager
        .requestWhenInUseAuthorization(id: LocationManagerId())
        .fireAndForget()
      #endif

    case .restricted:
      state.alert = .init(
        title: TextState("Please give us access to your location in settings"),
        message: TextState("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel(TextState("Cancel"), send: .alertDismissed),
        secondaryButton: .default(TextState(""), send: .popupSettings)
      )

      state.waitingForUpdateLocation = false
      return .none

    case .denied:
      state.alert = .init(
        title: TextState("Please give us access to your location in settings"),
        message: TextState("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel( TextState("Cancel"), send: .alertDismissed),
        secondaryButton: .default(TextState(""), send: .popupSettings)
      )
      state.waitingForUpdateLocation = false
      return .none

    case .authorizedAlways, .authorizedWhenInUse:
      state.isLocationAuthorized = true
      state.isConnected = true
      state.waitingForUpdateLocation = false

      return environment.locationManager
        .requestLocation(id: LocationManagerId())
        .fireAndForget()

    @unknown default:
      return .none
    }

  case .popupSettings:
    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    return .none

  case .dismissEventDetails:
    state.event = nil
    state.eventDetailsState = nil
    return .none

  case .eventForm(_):
    return .none

  case let .chat(isNavigate):
    return .none

  case let .eventDetailsView(isPresented: present):

    guard let event = state.event else { return .none }

    if present {
      let eventDetailsOverlayState = EventDetailsOverlayState(alert: nil, event: event)

      state.eventDetailsState = EventDetailsState(
        event: event,
        eventDetailsOverlayState: eventDetailsOverlayState
      )
    } else {
      state.eventDetailsState = nil
      state.event = nil
    }
    return .none

  case let .eventDetails(action):
    switch action {

    case .onAppear, .alertDismissed, .moveToChatRoom(_), .updateRegion(_):
      return .none

    case let .eventDetailsOverlay(eventDetailsAction):
      switch eventDetailsAction {
      case .onAppear, .alertDismissed:
        return .none
      case let .startChat(present):
        return presentChatView()

      case let .askJoinRequest(bool):
        state.isMovingChatRoom = bool
        return .none

      case let .joinToEvent(.success(string)): // joinToEventRequest
        return presentChatView()

      case let .joinToEvent(.failure(error)): // joinToEventRequest
        return .none
      case let .conversationResponse(.success(conversationItem)):
        state.conversation = conversationItem
        return .none
      case let .conversationResponse(.failure(error)):
        return .none
      }
    }

  case .chatView(isNavigate: let isNavigate):
    state.chatState = isNavigate ? ChatState(conversation: state.conversation) : nil
    return .none

  }
}
.presents(
  chatReducer,
  state: \.chatState,
  action: /EventsAction.chat,
  environment: {
    ChatEnvironment(
      chatClient: ChatClient.live(api: .build),
      websocketClient: .live,
      mainQueue: $0.mainQueue,
      backgroundQueue: $0.backgroundQueue
    )
  }
)
.presents(
  eventDetailsReducer,
  state: \.eventDetailsState,
  action: /EventsAction.eventDetails,
  environment: {
    EventDetailsEnvironment(
      conversationClient: ConversationClient.live(api: .build),
      mainQueue: $0.mainQueue
    )
  }
)
