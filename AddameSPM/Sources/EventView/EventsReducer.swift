import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import ComposableCoreLocation
import Contacts
import HangoutDetailsFeature
import EventFormView
import AddaSharedModels
import SwiftUI
import MapView
import AdSupport
import AppTrackingTransparency
import IDFAClient
import Dependencies
import LocationReducer

import UserDefaultsClient
import APIClient

public struct Hangouts: ReducerProtocol {

    public struct State: Equatable {
        public init(
            alert: AlertState<Hangouts.Action>? = nil,
            isConnected: Bool = true,
            isLoadingPage: Bool = false,
            isLoadingMyEvent: Bool = false,
            canLoadMorePages: Bool = true,
            isMovingChatRoom: Bool = false,
            isEFromNavigationActive: Bool = false,
            isIDFAAuthorized: Bool = false,
            isLocationAuthorizedCount: Int = 0,
            currentPage: Int = 1,
            currentAddress: String = "",
            location: Location? = nil,
            events: IdentifiedArrayOf<EventResponse> = [],
            myEvent: EventResponse? = nil,
            event: EventResponse? = nil,
            conversation: ConversationOutPut? = nil,
            locationState: LocationReducer.State = .init()
        ) {
            self.alert = alert
            self.isConnected = isConnected
            self.isLoadingPage = isLoadingPage
            self.isLoadingMyEvent = isLoadingMyEvent
            self.canLoadMorePages = canLoadMorePages
            self.isMovingChatRoom = isMovingChatRoom
            self.isEFromNavigationActive = isEFromNavigationActive
            self.isIDFAAuthorized = isIDFAAuthorized
            self.isLocationAuthorizedCount = isLocationAuthorizedCount
            self.currentPage = currentPage
            self.currentAddress = currentAddress
            self.events = events
            self.myEvent = myEvent
            self.event = event
            self.conversation = conversation
            self.locationState = locationState
        }

        public var alert: AlertState<Hangouts.Action>?
        public var isConnected = true
        public var isLoadingPage = true
        public var isLoadingMyEvent = false
        public var canLoadMorePages = true
        public var isMovingChatRoom: Bool = false
        public var isEFromNavigationActive = false
        public var isIDFAAuthorized = false
        public var isLocationAuthorizedCount = 0

        public var currentPage = 1
        public var currentAddress = ""
        
        public var events: IdentifiedArrayOf<EventResponse> = []
        public var myEvent: EventResponse?
        public var event: EventResponse?
        public var conversation: ConversationOutPut?

        public var locationState: LocationReducer.State
        
        public var hangoutFormState: HangoutForm.State?
        public var isHangoutDetailsSheetPresented: Bool { hangoutDetailsState != nil }


        public var hangoutDetailsState: HangoutDetails.State?
        public var isHangoutNavigationActive: Bool = false
        //          public var chatState: ChatState?


    }

    public enum Action: Equatable {
        case onAppear
        case onDisAppear
        case alertDismissed
        case dismissHangoutDetails

        case event(index: EventResponse.ID, action: EventAction)

        case hangoutFormView(isNavigate: Bool)
        case hangoutForm(HangoutForm.Action)

        case hangoutDetailsSheet(isPresented: Bool)
        case hangoutDetails(HangoutDetails.Action)

        case chatView(isNavigate: Bool)
        case chat(ChatAction)

        case fetchEventOnAppear
        case fetchMoreEventsIfNeeded(item: EventResponse?)
        case currentLocationButtonTapped
        case locationManager(LocationManager.Action)
        case eventsResponse(TaskResult<EventsResponse>)
        case eventTapped(EventResponse)
        case myEventsResponse(TaskResult<EventsResponse>)

        //case idfaAuthorizationStatus(ATTrackingManager.AuthorizationStatus)

        case popupSettings
        case dismissEvent
        case location(LocationReducer.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.build) var build

    public init() {}

    enum LocationManagerId: Hashable {}

    public var body: some ReducerProtocol<State, Action> {

        Scope(state: \.locationState, action: /Action.location) {
           LocationReducer()
        }

        Reduce(self.core)
            .ifLet(\.hangoutFormState, action: /Hangouts.Action.hangoutForm) {
                HangoutForm()
            }
            .ifLet(\.hangoutDetailsState, action: /Hangouts.Action.hangoutDetails) {
                HangoutDetails()
            }
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {

        var fetchEvents: Effect<Action, Never> {
        guard state.isConnected && state.canLoadMorePages,
                let location = state.locationState.location
        else {
            return .none
        }

        let getDistanceType = userDefaults.integerForKey("typee") //userDefaults.integerForKey("typee")
        let maxDistance = getDistanceType == 0 ? (300 * 1000) : (300 / 1.609) * 1609
        let distanceType: String = getDistanceType == 0 ? "kilometers" : "miles"
        let getDistance = userDefaults.doubleForKey("distanceType")
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

            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude

            let query = EventPageRequest(
                page: state.currentPage,
                par: 10,
                lat: lat, long: long,
                distance: distanceInMeters
            )

            return  .task {
                .eventsResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .eventEngine(.events(.list(query: query))),
                            as: EventsResponse.self,
                            decoder: .iso8601
                        )
                    }
                )
            }
        }

          func presentChatView() -> Effect<Action, Never> {
            state.hangoutDetailsState = nil
//            state.chatState = nil
            return Effect(value: Action.chatView(isNavigate: true))
              .receive(on: mainQueue)
              .eraseToEffect()
          }

        switch action {
        case .onAppear:

            return .run { send in
                await send(.location(.callDelegateThenGetLocation))
                try await self.mainQueue.sleep(for: .seconds(0.3))
                await send(.fetchEventOnAppear)
            }

        case .onDisAppear:
            return .none
        case .alertDismissed:
            return .none
        case .dismissHangoutDetails:
            return .none
        case .hangoutFormView(isNavigate: let active):
            guard let placeMark = state.locationState.placeMark
            else {
              // pop alert let user know about issue
              return .none
            }

            state.hangoutFormState = active ? HangoutForm.State(placeMark: placeMark) : nil

            return .none

      case let .hangoutForm(.eventResponse(.success(event))):
        state.events.insert(event, at: 0)
        return .none

        case .hangoutForm(.backToPVAfterCreatedEventSuccessfully):
            state.hangoutFormState = nil
            return .none

        case .hangoutForm:
            return .none
    
        case  let .hangoutDetailsSheet(isPresented: isPresented):

            guard let event = state.event else { return .none }

            state.hangoutDetailsState = isPresented ? HangoutDetails.State(event: event) : nil
            return .none

        case .eventTapped(let hangout):
            state.event = hangout
            return .run { send in
                await send(.hangoutDetailsSheet(isPresented: true))
            }

        case .chatView(isNavigate: let isNavigate):
            return .none

        case .chat(_):
            return .none
        case .fetchEventOnAppear:
            let isLocationAuthorized = state.locationState.isLocationAuthorized

            if isLocationAuthorized {
              return fetchEvents
            }

        return .none
        case .fetchMoreEventsIfNeeded(item: let item):
            guard let item = item, state.events.count > 5 else {
              return fetchEvents
            }

            let threshouldIndex = state.events.index(state.events.endIndex, offsetBy: -5)
            if state.events.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
              return fetchEvents
            }

            return .none

        case .currentLocationButtonTapped:
            return .none
        case .locationManager(_):
            return .none
        case .eventsResponse(.success(let eventArray)):
            
            state.locationState.waitingForUpdateLocation = false

            state.isLoadingPage = false

            eventArray.items.forEach {
                if state.events[id: $0.id] != $0 {
                    state.events.append($0)
                }
            }

            state.canLoadMorePages = state.events.count < eventArray.metadata.total
            if state.canLoadMorePages {
                state.currentPage += 1
            }

            return .none

        case .eventsResponse(.failure(_)):
            return .none
        case .myEventsResponse:
            return .none
        
        case .popupSettings:
            return .none
        case .dismissEvent:
            return .none

        case .location:
            return .none

        case .hangoutDetails(let hdAction):
            switch hdAction {
            case .onAppear:
                return .none
            case .alertDismissed:
                return .none
            case .moveToChatRoom:
                return .none
            case .updateRegion:
                return .none
            case .startChat:
                return presentChatView()
            case .askJoinRequest(let boolean):
                state.isMovingChatRoom = boolean
                return .none

            case .joinToEvent(.success):
                return presentChatView()
            case .joinToEvent(.failure):
                /// handle error here
                return .none
            case let .conversationResponse(.success(conversationItem)):
                state.conversation = conversationItem
                return .none
            case .conversationResponse(.failure):
                /// handle error here
                return .none
            case .userResponse:
                return .none
            }
        }

    }
}

// import ChatView
// import Combine
// import ComposableArchitecture
// import ComposableArchitectureHelpers
// import ComposableCoreLocation
// import Contacts
// import HangoutDetailsFeature
// import EventFormView
// import HTTPRequestKit
// import MapKit
// import AddaSharedModels
// import SwiftUI
// import MapView
//
// enum LocationManagerId: Hashable {}
// enum IDFAStatusId: Hashable {}
//
//// swiftlint:disable superfluous_disable_command file_length
// public let eventsReducer = Reducer<EventsState, EventsAction, EventsEnvironment> {
//  state, action, environment in
//
//  var currentLocationButtonTapped: Effect<EventsAction, Never> {
//    guard environment.locationManager.locationServicesEnabled() else {
//      state.alert = .init(title: TextState("Location services are turned off."))
//      state.waitingForUpdateLocation = false
//      return .none
//    }
//
//    switch environment.locationManager.authorizationStatus() {
//    case .notDetermined:
//      state.isRequestingCurrentLocation = true
//      state.waitingForUpdateLocation = true
//      #if os(macOS)
//        return environment.locationManager
//          .requestAlwaysAuthorization()
//          .fireAndForget()
//      #else
//        return environment.locationManager
//          .requestWhenInUseAuthorization()
//          .fireAndForget()
//      #endif
//
//    case .restricted:
//        state.isLocationAuthorized = false
//      return .none
//
//    case .denied:
//        state.isLocationAuthorized = false
//      return .none
//
//    case .authorizedAlways, .authorizedWhenInUse:
//      state.isLocationAuthorized = true
//      state.isConnected = true
//      state.waitingForUpdateLocation = false
//
//      return environment.locationManager.startUpdatingLocation()
//            .fireAndForget()
//
//    @unknown default:
//      return .none
//    }
//  }
//
//  var fetchEvents: Effect<EventsAction, Never> {
//    guard state.isConnected && state.canLoadMorePages,
//          let location = state.location
//    else {
//      return .none
//    }
//
//    state.location = location
//
//    let getDistanceType = environment.userDefaults.integerForKey("typee")
//    let maxDistance = getDistanceType == 0 ? (300 * 1000) : (300 / 1.609) * 1609
//    let distanceType: String = getDistanceType == 0 ? "kilometers" : "miles"
//    let getDistance = environment.userDefaults.doubleForKey(distanceType)
//    var distanceInMeters: Double = 0.0
//
//    if getDistance != 0.0 {
//      if getDistanceType == 0 {
//        distanceInMeters = getDistance * 1000
//      } else {
//        distanceInMeters = getDistance * 1609
//      }
//    } else {
//      if distanceType == "kilometers" {
//        distanceInMeters = maxDistance
//      } else {
//        distanceInMeters = maxDistance
//      }
//    }
//
//      let lat = location.coordinate.latitude
//      let long = location.coordinate.longitude
//
//      let query = EventPageRequest(
//          page: state.currentPage,
//          par: 10,
//          lat: lat, long: long,
//          distance: distanceInMeters
//      )
//
//      return  .task {
//          do {
//              print(#line, query)
//            let events = try await environment.eventClient.events(query)
//            return  EventsAction.eventsResponse(events)
//          } catch {
//              return EventsAction.eventsResponseError(HTTPRequest.HRError.custom("fetch events get error", error))
//          }
//      }
//  }
//
//  func getPlacemark(_ location: Location) -> Effect<EventsAction, Never> {
//    return environment.getPlacemark(location)
//      .receive(on: environment.mainQueue)
//      .catchToEffect()
//      .map(EventsAction.eventPlacemarkResponse)
//  }
//
//  func presentChatView() -> Effect<EventsAction, Never> {
//    state.eventDetailsState = nil
//    state.chatState = nil
//    return Effect(value: EventsAction.chatView(isNavigate: true))
//      .receive(on: environment.mainQueue)
//      .eraseToEffect()
//  }
//
//  switch action {
//
//  case .onAppear:
//
//    return .merge(
//      environment.locationManager.delegate()
//        .receive(on: environment.mainQueue)
//        .eraseToEffect()
//        .map(EventsAction.locationManager)
//        .cancellable(id: LocationManagerId.self),
//
//      currentLocationButtonTapped,
//
//      environment.idfaClient.requestAuthorization()
//        .receive(on: environment.mainQueue)
//        .map(EventsAction.idfaAuthorizationStatus)
//        .eraseToEffect()
//        .cancellable(id: IDFAStatusId.self),
//
//      fetchEvents
//    )
//  case .onDisAppear:
//      state.canLoadMorePages = true
//
//      return .none
//  case .fetchEventOnAppear:
//      let isLocationAuthorized = state.isLocationAuthorized
//      state.isLocationAuthorizedCount += 1
//
//      if isLocationAuthorized && state.isLocationAuthorizedCount == 1 {
//          return fetchEvents
//      }
//
//    return .none
//
//  case .dismissEvent:
//    return .none
//
//  case .alertDismissed:
//    state.alert = nil
//    return .none
//
//  case let .fetchMoreEventsIfNeeded(item):
//
//    guard let item = item, state.events.count > 5 else {
//      return fetchEvents
//    }
//
//    let threshouldIndex = state.events.index(state.events.endIndex, offsetBy: -5)
//    if state.events.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
//      return fetchEvents
//    }
//
//    return .none
//
//  case let .event(index: index):
//    return .none
//
//  case let .eventsResponse(eventArray):
//
//    state.waitingForUpdateLocation = false
//
//    state.isLoadingPage = false
//
//    eventArray.items.forEach {
//        if state.events[id: $0.id] != $0 {
//            state.events.append($0)
//        }
//    }
//
//      state.canLoadMorePages = state.events.count < eventArray.metadata.total
//      if state.canLoadMorePages {
//          state.currentPage += 1
//      }
//
//    return .none
//
//  case let .eventsResponseError(error):
//    state.isLoadingPage = false
//    state.alert = .init(title: TextState(error.description))
//
//    return .none
//
//  case let .eventTapped(event):
//    state.event = event
//    return Effect(value: EventsAction.eventDetailsView(isPresented: true))
//      .receive(on: environment.mainQueue)
//      .eraseToEffect()
//
//  case let .myEventsResponse(.success(myEventsResponse)):
//      state.myEvent = myEventsResponse.items.last
//      state.isLoadingMyEvent = false
//      return .none
//
//  case let .myEventsResponse(.failure(error)):
//      state.isLoadingMyEvent = false
//      return .none
//
//  case let .addressResponse(.success(address)):
//    return .none
//
//  case let .eventPlacemarkResponse(.success(placemark)):
//
//    let formatter = CNPostalAddressFormatter()
//    guard let postalAddress = placemark.postalAddress else {
//      // handle error here
//      return .none
//    }
//    let addressString = formatter.string(from: postalAddress)
//    state.currentAddress = addressString
//    state.placeMark = placemark
//
//      return .cancel(id: LocationManagerId.self)
//
//  case let .locationManager(.didUpdateLocations(locations)):
//
//    guard state.isConnected,
//            let location = locations.first
//      else { return .none }
//
//    state.location = location
//
//    return .merge(
//        Effect(value: .fetchEventOnAppear)
//            .receive(on: environment.mainQueue)
//            .eraseToEffect(),
//      getPlacemark(location)
//    )
//
//  case .locationManager:
//    return .none
//
//  case .currentLocationButtonTapped:
//    return currentLocationButtonTapped
//
//  case .popupSettings:
//      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//
//    return .none
//
//  case .dismissHangoutDetails:
//    state.event = nil
//    state.eventDetailsState = nil
//    return .none
//
//  case let .eventFormView(isNavigate: active):
//
//    guard
//      let placeMark = state.placeMark,
//      let location = placeMark.location
//    else {
//      // pop alert let user know about issue
//      return .none
//    }
//
//    state.eventFormState =
//      active
//      ? EventFormState(
//        placeMark: state.placeMark,
//        eventAddress: state.currentAddress,
//        eventCoordinate: location.coordinate
//      )
//      : nil
//
//    return .none
//
//  case let .eventForm(.eventsResponse(.success(event))):
//    state.events.insert(event, at: 0)
//    return .none
//
//  case .eventForm(.backToPVAfterCreatedEventSuccessfully):
//    state.eventFormState = nil
//    return .none
//
//  case .eventForm:
//    return .none
//
//  case let .chat(isNavigate):
//    return .none
//
//  case let .eventDetailsView(isPresented: present):
//
//    guard let event = state.event else { return .none }
//
//    if present {
//      let eventDetailsOverlayState = HangoutDetailsOverlayState(alert: nil, event: event)
//
//      state.eventDetailsState = HangoutDetailsState(
//        event: event,
//        eventDetailsOverlayState: eventDetailsOverlayState
//      )
//    } else {
//      state.eventDetailsState = nil
//      state.event = nil
//    }
//    return .none
//
//  case let .eventDetails(action):
//    switch action {
//    case .onAppear, .alertDismissed, .moveToChatRoom(_), .updateRegion:
//      return .none
//
//    case let .eventDetailsOverlay(eventDetailsAction):
//      switch eventDetailsAction {
//      case .onAppear, .alertDismissed:
//        return .none
//      case let .startChat(present):
//        return presentChatView()
//
//      case let .askJoinRequest(bool):
//        state.isMovingChatRoom = bool
//        return .none
//
//      case let .joinToEvent(.success(string)):  // joinToEventRequest
//        return presentChatView()
//
//      case let .joinToEvent(.failure(error)):  // joinToEventRequest
//        return .none
//      case let .conversationResponse(.success(conversationItem)):
//        state.conversation = conversationItem
//        return .none
//      case let .conversationResponse(.failure(error)):
//        return .none
//      }
//    }
//
//  case let .chatView(isNavigate: isNavigate):
//    state.chatState = isNavigate ? ChatState(conversation: state.conversation) : nil
//    return .none
//  case .idfaAuthorizationStatus(let status):
//      state.isIDFAAuthorized = state.isIDFAAuthorization(status)
//      return .none
//  }
// }
//
//// .combine(myEventsReducer
////       .optional()
////       .pullback(
////      state: \.myEvent,
////      action: /EventsAction.myEventAction),
////      environment: { _ in MyEventsEnvironment.live }
//// )
// .combined(
//  with: locationManagerReducer
//    .pullback(state: \.self, action: /EventsAction.locationManager, environment: { $0 })
// )
// .signpost()
// .debug()
// .presenting(
//  eventFormReducer,
//  state: .keyPath(\.eventFormState),
//  id: .notNil(),
//  action: /EventsAction.eventForm,
//  environment: { _ in EventFormEnvironment.live }
// )
// .presenting(
//  chatReducer,
//  state: .keyPath(\.chatState),
//  id: .notNil(),
//  action: /EventsAction.chat,
//  environment: { _ in ChatEnvironment.live }
// )
// .presenting(
//  eventDetailsReducer,
//  state: .keyPath(\.eventDetailsState),
//  id: .notNil(),
//  action: /EventsAction.eventDetails,
//  environment: { _ in HangoutDetailsEnvironment.live }
// )
// .debug()
//
// private let locationManagerReducer = Reducer<
//  EventsState, LocationManager.Action, EventsEnvironment
// > { state, action, environment in
//
//  switch action {
//  case .didChangeAuthorization(.authorizedAlways),
//    .didChangeAuthorization(.authorizedWhenInUse):
//
//    state.isLocationAuthorized = true
//    state.isConnected = true
//    state.waitingForUpdateLocation = false
//
//    if state.isRequestingCurrentLocation {
//      return environment.locationManager
//        .startUpdatingLocation()
//        .fireAndForget()
//    }
//      return .none
//
//  case .didChangeAuthorization(.denied),
//    .didChangeAuthorization(.restricted):
//
//    state.waitingForUpdateLocation = false
//    state.isLocationAuthorized = false
//    state.isConnected = false
//    return .none
//
//  case let .didUpdateLocations(locations):
//    state.isRequestingCurrentLocation = false
//
//    return .none
//
//  default:
//    return .none
//  }
// }
//
// extension MKPlacemark {
//  var formattedAddress: String? {
//    guard let postalAddress = postalAddress else { return nil }
//    return CNPostalAddressFormatter.string(
//      from: postalAddress, style: .mailingAddress
//    )
//    .replacingOccurrences(of: "\n", with: " ")
//  }
// }
