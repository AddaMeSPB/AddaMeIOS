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
import ComposableCoreLocation
import ComposableArchitectureHelpers

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

import EventClient
import EventClientLive

// swiftlint:disable file_length
struct Foo {
  @AppStorage("isAuthorized")
  public static var isAuthorized: Bool = false
}

struct LocationManagerId: Hashable {}

public let eventReducer = Reducer<EventsState, EventsAction, EventsEnvironment> { state, action, environment in

  var fetchEvents: Effect<EventsAction, Never> {
    guard state.isConnected, let location = state.location else { return .none }
    state.location = location

    guard !state.isLoadingPage && state.canLoadMorePages else { return .none }

    // state.isLoadingPage = true

    let getDistanceType = environment.userDefaults.integerForKey("typee")
    let maxDistance = getDistanceType == 0 ? (250 * 1000) : (250 / 1.609) * 1609
    let distanceType: String = getDistanceType == 0 ? "kilometers" : "miles"
    let getDistance = environment.userDefaults.doubleForKey(distanceType)
    var distanceInMeters: Double = 0.0

    if getDistance != 0.0 {
      if getDistanceType == 0 {
        distanceInMeters = getDistance * 1000
      } else {
        distanceInMeters = getDistance * 1609
      }
    } else {
      if distanceType == "kilometers" {
        distanceInMeters = maxDistance
      } else {
        distanceInMeters = maxDistance
      }
    }

    let lat = "\(location.coordinate.latitude)"
    let long = "\(location.coordinate.longitude)"
    print(#line, distanceInMeters)
    let query = QueryItem(
      page: "\(state.currentPage)",
      per: "10", lat: lat, long: long,
      distance: "\(Int(distanceInMeters))"
    )

    return environment.eventClient.events(query, "")
      .retry(3)
      .receive(on: environment.mainQueue.animation(.default))
      .removeDuplicates()
      .catchToEffect()
      .map(EventsAction.eventsResponse)
  }

  func getLocation(_ location: Location) -> Effect<EventsAction, Never> {
    return environment.getCoordinate(location)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EventsAction.eventCoordinate)
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

    guard
      let placeMark = state.placeMark,
      let location = placeMark.location
    else {
      // pop alert let user know about issue
      return .none
    }

    state.eventFormState = active
    ? EventFormState(
      placeMark: state.placeMark,
      eventAddress: state.currentAddress,
      eventCoordinate: location.coordinate
    )
    : nil

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

  case let .fetchMoreEventsIfNeeded(item):

    guard let item = item, state.events.count > 5 else {
      return fetchEvents
    }

    let threshouldIndex = state.events.index(state.events.endIndex, offsetBy: -5)
    if state.events.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
      return fetchEvents
    }

    return .none

  case .event(index: let index):

    return .none
  case .eventsResponse(.success(let eventArray)):

    state.waitingForUpdateLocation = false
    state.canLoadMorePages = state.events.count < eventArray.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    let events = (state.events + eventArray.items)
//      .uniqElemets()
//      .sorted()

    state.events
    = .init(uniqueElements: events)

    return .none

  case .eventsResponse(.failure(let error)):
    state.isLoadingPage = false
    state.alert = .init(title: TextState(error.description))

    return .none

  case .eventTapped(let event):
    state.event = event
    return Effect(value: EventsAction.eventDetailsView(isPresented: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()

  case .addressResponse(.success(let address)):
    return .none

  case let .eventCoordinate(.success(placemark)):
    let formatter = CNPostalAddressFormatter()
    let addressString = formatter.string(from: placemark.postalAddress!)
    state.currentAddress = addressString
    state.placeMark = placemark

    return .none

  case let .locationManager(.didUpdateLocations(locations)):

    guard state.isConnected, let location = locations.first else { return .none }
    state.location = location

    return .merge(
      fetchEvents,
      getLocation(location)
    )

  case .locationManager:
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
//    @available(iOSApplicationExtension, unavailable)
//    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
//      UIApplication.shared.open(url, options: [:], completionHandler: nil)
//    }

    return .none

  case .dismissEventDetails:
    state.event = nil
    state.eventDetailsState = nil
    return .none

  case .eventForm(.backToPVAfterCreatedEventSuccessfully):
     state.eventFormState = nil
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
.combined(
  with:
    locationManagerReducer
    .pullback(state: \.self, action: /EventsAction.locationManager, environment: { $0 })
)
// .signpost()
.debug()

.presents(
  eventFormReducer,
  state: \.eventFormState,
  action: /EventsAction.eventForm,
  environment: {
    EventFormEnvironment(
      eventClient: EventClient.live(api: .build),
      mainQueue: $0.mainQueue
    )
  }
)
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

public let locationManagerReducer = Reducer<
  EventsState, LocationManager.Action, EventsEnvironment
> { state, action, environment in

  switch action {
  case .didChangeAuthorization(.authorizedAlways),
       .didChangeAuthorization(.authorizedWhenInUse):

    state.isLocationAuthorized = true
    state.isConnected = true

    return environment.locationManager
      .requestLocation(id: LocationManagerId())
      .fireAndForget()

  case .didChangeAuthorization(.denied),
       .didChangeAuthorization(.restricted):

    state.isLocationAuthorized = false
    state.isConnected = false

    state.alert = .init(
      title: TextState("Please give us access to your location so you can use our full features"),
      message: TextState("Please go to Settings and turn on the permissions"),
      primaryButton: .cancel(TextState("Cancel"), send: .alertDismissed),
      secondaryButton: .default(TextState("Go Settings"), send: .popupSettings)
    )
    return .none

  case let .didUpdateLocations(locations):
    return .none

  case .didChangeAuthorization(.notDetermined):
    return .none
  case .didChangeAuthorization(let status):
    print(#line, status)
    return .none
  case .didDetermineState(_, region: let region):
    print(#line, region)
    return .none
  case .didEnterRegion(_):
    return .none
  case .didExitRegion(_):
    return .none
  case let .didFailRanging(beaconConstraint: beaconConstraint, error: error):
    return .none
  case .didFailWithError(_):
    return .none
  case .didFinishDeferredUpdatesWithError(_):
    return .none
  case .didPauseLocationUpdates:
    return .none
  case .didResumeLocationUpdates:
    return .none
  case .didStartMonitoring(region: let region):
    return .none
  case .didUpdateHeading(newHeading: let newHeading):
    return .none
  case let .didUpdateTo(newLocation: newLocation, oldLocation: oldLocation):
    return .none
  case .didVisit(_):
    return .none
  case let .monitoringDidFail(region: region, error: error):
    return .none
  case .didRangeBeacons(_, satisfyingConstraint: let satisfyingConstraint):
    return .none
  }
}

import Contacts

extension MKPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress, style: .mailingAddress)
      .replacingOccurrences(of: "\n", with: " "
      )
  }
}
