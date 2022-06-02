//
//  EventReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import ComposableCoreLocation
import Contacts
import EventDetailsView
import EventFormView
import HTTPRequestKit
import MapKit
import SharedModels
import SwiftUI
import MapView

struct LocationManagerId: Hashable {}

// swiftlint:disable superfluous_disable_command file_length
public let eventsReducer = Reducer<EventsState, EventsAction, EventsEnvironment> {
  state, action, environment in

  var currentLocationButtonTapped: Effect<EventsAction, Never> {
    guard environment.locationManager.locationServicesEnabled() else {
      state.alert = .init(title: TextState("Location services are turned off."))
      state.waitingForUpdateLocation = false
      return .none
    }

    switch environment.locationManager.authorizationStatus() {
    case .notDetermined:
      state.isRequestingCurrentLocation = true
      state.waitingForUpdateLocation = true
      #if os(macOS)
        return environment.locationManager
          .requestAlwaysAuthorization()
          .fireAndForget()
      #else
        return environment.locationManager
          .requestWhenInUseAuthorization()
          .fireAndForget()
      #endif

    case .restricted:
      state.alert = .init(
        title: .init("Please give us access to your location in settings"),
        message: .init("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel(.init("Cancel"), action: .send(.alertDismissed)),
        secondaryButton: .default(.init(""), action: .send(.popupSettings))
      )
      state.waitingForUpdateLocation = false
      return .none

    case .denied:
      state.alert = .init(
        title: .init("Please give us access to your location in settings"),
        message: .init("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel(.init("Cancel"), action: .send(.alertDismissed)),
        secondaryButton: .default(TextState(""), action: .send(.popupSettings))
      )
      state.waitingForUpdateLocation = false
      return .none

    case .authorizedAlways, .authorizedWhenInUse:
      state.isLocationAuthorized = true
      state.isConnected = true
      state.waitingForUpdateLocation = false

        return environment.locationManager.startUpdatingLocation()
            .fireAndForget()

//        environment.locationManager
//          .requestLocation()
//          .fireAndForget()

    @unknown default:
      return .none
    }
  }

  var fetchEvents: Effect<EventsAction, Never> {
    guard state.isConnected && state.canLoadMorePages,
          let location = state.location
    else {
      return .none
    }

    state.location = location

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

  func getPlacemark(_ location: Location) -> Effect<EventsAction, Never> {
    return environment.getPlacemark(location)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EventsAction.eventPlacemarkResponse)
  }

  func presentChatView() -> Effect<EventsAction, Never> {
    state.eventDetailsState = nil
    state.chatState = nil
    return Effect(value: EventsAction.chatView(isNavigate: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()
  }

  switch action {
  case .onAppear:

    return .merge(
      environment.locationManager.delegate()
        .map(EventsAction.locationManager)
        .cancellable(id: LocationManagerId()),

      currentLocationButtonTapped
    )

  case .dismissEvent:
    return .none

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

  case let .event(index: index):

    return .none
  case let .eventsResponse(.success(eventArray)):

    state.waitingForUpdateLocation = false
    state.canLoadMorePages = state.events.count < eventArray.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    eventArray.items.forEach {
      if !state.events.contains($0) {
        state.events.append($0)
      }
    }

    return .none

  case let .eventsResponse(.failure(error)):
    state.isLoadingPage = false
    state.alert = .init(title: TextState(error.description))

    return .none

  case let .eventTapped(event):
    state.event = event
    return Effect(value: EventsAction.eventDetailsView(isPresented: true))
      .receive(on: environment.mainQueue)
      .eraseToEffect()

  case let .addressResponse(.success(address)):
    return .none

  case let .eventPlacemarkResponse(.success(placemark)):
    let formatter = CNPostalAddressFormatter()
    guard let postalAddress = placemark.postalAddress else {
      // handle error here
      return .none
    }
    let addressString = formatter.string(from: postalAddress)
    state.currentAddress = addressString
    state.placeMark = placemark

    return .none

  case let .locationManager(.didUpdateLocations(locations)):
    state.isLoadingPage = true
    guard state.isConnected, let location = locations.first else { return .none }
    state.location = location

    return .merge(
      fetchEvents,
      getPlacemark(location)
    )

  case .locationManager:
    return .none

  case .currentLocationButtonTapped:
    return currentLocationButtonTapped

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

  case let .eventFormView(isNavigate: active):

    guard
      let placeMark = state.placeMark,
      let location = placeMark.location
    else {
      // pop alert let user know about issue
      return .none
    }

    state.eventFormState =
      active
      ? EventFormState(
        placeMark: state.placeMark,
        eventAddress: state.currentAddress,
        eventCoordinate: location.coordinate
      )
      : nil

    return .none

  case let .eventForm(.eventsResponse(.success(event))):
    state.events.insert(event, at: 0)
    return .none

  case .eventForm(.backToPVAfterCreatedEventSuccessfully):
    state.eventFormState = nil
    return .none

  case .eventForm:
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
    case .onAppear, .alertDismissed, .moveToChatRoom(_), .updateRegion:
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

      case let .joinToEvent(.success(string)):  // joinToEventRequest
        return presentChatView()

      case let .joinToEvent(.failure(error)):  // joinToEventRequest
        return .none
      case let .conversationResponse(.success(conversationItem)):
        state.conversation = conversationItem
        return .none
      case let .conversationResponse(.failure(error)):
        return .none
      }
    }

  case let .chatView(isNavigate: isNavigate):
    state.chatState = isNavigate ? ChatState(conversation: state.conversation) : nil
    return .none
  }
}
.combined(
  with: locationManagerReducer
    .pullback(state: \.self, action: /EventsAction.locationManager, environment: { $0 })
)
.signpost()
.debug()
.presenting(
  eventFormReducer,
  state: \.eventFormState,
  action: /EventsAction.eventForm,
  environment: { _ in EventFormEnvironment.live }
)
.presenting(
  chatReducer,
  state: \.chatState,
  action: /EventsAction.chat,
  environment: { _ in ChatEnvironment.live }
)
.presenting(
  eventDetailsReducer,
  state: \.eventDetailsState,
  action: /EventsAction.eventDetails,
  environment: { _ in EventDetailsEnvironment.live }
)
.debug()

private let locationManagerReducer = Reducer<
  EventsState, LocationManager.Action, EventsEnvironment
> { state, action, environment in

  switch action {
  case .didChangeAuthorization(.authorizedAlways),
    .didChangeAuthorization(.authorizedWhenInUse):

    state.isLocationAuthorized = true
    state.isConnected = true
    state.waitingForUpdateLocation = false

    if state.isRequestingCurrentLocation {
      return environment.locationManager
        .startUpdatingLocation()
        .fireAndForget()
    }
    return .none

  case .didChangeAuthorization(.denied),
    .didChangeAuthorization(.restricted):

    state.waitingForUpdateLocation = false
    state.isLocationAuthorized = false
    state.isConnected = false

    state.alert = .init(
      title: TextState("Please give us access to your location so you can use our full features"),
      message: TextState("Please go to Settings and turn on the permissions"),
      primaryButton: .cancel(.init("Cancel"), action: .send(.alertDismissed)),
      secondaryButton: .default(.init("Go Settings"), action: .send(.popupSettings))
    )
    return .none

  case let .didUpdateLocations(locations):
    state.isRequestingCurrentLocation = false

    return .none

  default:
    return .none
  }
}

extension MKPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress, style: .mailingAddress
    )
    .replacingOccurrences(of: "\n", with: " ")
  }
}
