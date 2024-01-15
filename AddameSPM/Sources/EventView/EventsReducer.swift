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
import WebSocketReducer

import SettingsFeature

//public struct Hangouts: Reducer {
//    public struct State: Equatable {
//        public var locationState: LocationReducer.State
//    }
//
//    public enum Action: Equatable {
//        case locationManager(LocationManager.Action)
//    }
//
//    public var body: some Reducer<State, Action> {
//
//        Scope(state: \.locationState, action: /Action.location) {
//            LocationReducer()
//        }
//
//        Reduce(self.core)
//
//        func core(state: inout State, action: Action) -> Effect<Action> {}
//    }
//}

public struct Hangouts: Reducer {

    public struct State: Equatable {
        public init(
            alert: AlertState<Hangouts.AlertAction>? = nil,
            isConnected: Bool = true,
            isLoadingPage: Bool = false,
            isLoadingMyEvent: Bool = false,
            canLoadMorePages: Bool = true,
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
            locationState: LocationReducer.State = .init(),
            chatState: Chat.State? = nil,
            websocketState: WebSocketReducer.State
        ) {
            self.alert = alert
            self.isConnected = isConnected
            self.isLoadingPage = isLoadingPage
            self.isLoadingMyEvent = isLoadingMyEvent
            self.canLoadMorePages = canLoadMorePages
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
            self.chatState = chatState
            self.websocketState = websocketState
        }

        @PresentationState var alert: AlertState<AlertAction>?
        public var isConnected = true
        public var isLoadingPage = true
        public var isLoadingMyEvent = false
        public var canLoadMorePages = true

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
        public var chatState: Chat.State?
        public var isMovingChatRoom: Bool { chatState != nil }


        public var websocketState: WebSocketReducer.State

    }

    public enum Action: Equatable {
        case alert(PresentationAction<AlertAction>)
        case onAppear
        case onDisAppear
        case alertDismissed
        case dismissHangoutDetails

        case event(index: EventResponse.ID, action: EventRowReducer.Action)

        case hangoutFormView(isNavigate: Bool)
        case hangoutForm(HangoutForm.Action)

        case hangoutDetailsSheet(isPresented: Bool)
        case hangoutDetails(HangoutDetails.Action)

        case chatView(isNavigate: Bool)
        case chat(Chat.Action)

        case fetchEventOnAppear
        case fetchMoreEventsIfNeeded(item: EventResponse?)
        case currentLocationButtonTapped
        case locationManager(LocationManager.Action)
        case eventsResponse(TaskResult<EventsResponse>)
        case eventTapped(EventResponse)
        case myEventsResponse(TaskResult<EventsResponse>)
        case addUserResponse(TaskResult<AddUser>)

        //case idfaAuthorizationStatus(ATTrackingManager.AuthorizationStatus)

        case popupSettings
        case dismissEvent
        case location(LocationReducer.Action)
    }

    public enum AlertAction: Equatable {}

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.build) var build

    public init() {}

    enum LocationManagerId: Hashable {}

    public var body: some Reducer<State, Action> {

        Scope(state: \.locationState, action: /Action.location) {
           LocationReducer()
        }

        Reduce(self.core)
            .ifLet(\.$alert, action: /Action.alert)
            .ifLet(\.chatState, action: /Hangouts.Action.chat) {
                Chat()
            }
            .ifLet(\.hangoutFormState, action: /Hangouts.Action.hangoutForm) {
                HangoutForm()
            }
            .ifLet(\.hangoutDetailsState, action: /Hangouts.Action.hangoutDetails) {
                HangoutDetails()
            }
    }

    func core(state: inout State, action: Action) -> Effect<Action> {

        var fetchEvents: Effect<Action> {
            guard state.isConnected && state.canLoadMorePages,
                  let location = state.locationState.location
            else {
                return .none
            }

            // Calculate distance in meters
            let distanceInMeters = DistanceType.fetchCurrentDistanceInMeters(userDefaults: userDefaults)

            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude

            let query = EventPageRequest(
                page: state.currentPage,
                par: 10,
                lat: lat, long: long,
                distance: distanceInMeters
            )

            return  .run { send in
                await send(.eventsResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .eventEngine(.events(.list(query: query))),
                            as: EventsResponse.self,
                            decoder: .iso8601
                        )
                    }
                ))
            }
        }

        func presentChatView() -> Effect<Action> {
            state.hangoutDetailsState = nil
            return .run { send in
                try await self.mainQueue.sleep(for: .seconds(0.3))
                await send(.chatView(isNavigate: true))
            }
        }

        switch action {
        case .alert:
            return .none
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
            guard let conversation = state.conversation else { return .none }

            state.chatState = isNavigate ? Chat.State(
                conversation: conversation,
                currentUser: state.websocketState.user,
                websocketState: state.websocketState
            ) : nil

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
            guard let item = item, !state.events.isEmpty else {
                return fetchEvents
            }

            // Calculate the threshold index based on a percentage of the list's total count
            let thresholdPercentage = 0.2 // Adjust as needed
            let thresholdIndex = max(state.events.count - Int(Double(state.events.count) * thresholdPercentage), 0)

            if let itemIndex = state.events.firstIndex(where: { $0.id == item.id }), itemIndex >= thresholdIndex {
                return fetchEvents
            }

            return .none


        case .currentLocationButtonTapped:
            return .none

        case .locationManager:
            return .none

        case .eventsResponse(.success(let eventArray)):
            state.locationState.waitingForUpdateLocation = false
            state.isLoadingPage = false

            // Track if any new events were added
            var newEventsAdded = false

            for newEvent in eventArray.items {
                if !state.events.contains(where: { $0.id == newEvent.id }) {
                    state.events.append(newEvent)
                    newEventsAdded = true
                }
            }

            // Increment the page only if new events were added
            if newEventsAdded {
                state.currentPage += 1
            }

            // Update canLoadMorePages based on the total count and current array size
            state.canLoadMorePages = state.events.count < eventArray.metadata.total

            return .none


        case .eventsResponse(.failure(_)):
            return .none
        case .myEventsResponse:
            return .none

        case .popupSettings:
            return .none
        case .dismissEvent:
            return .none

        case .location(.placeMarkResponse(.success(let placemark))):

                let willFatchEventsAgain = state.events == []

                return .run { send in
                    if willFatchEventsAgain {
                        await send(.fetchEventOnAppear)
                    }
                }

        case .location:
            return .none



        case .addUserResponse(.success):
            return .run { send in
                await send(.hangoutDetails(.startChat(true)))
            }
        case .addUserResponse(.failure):
            return .none
        case .hangoutDetails(let hdAction):
            switch hdAction {
            case .alert:
                return .none
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

                guard let conversationId = state.event?.conversationsId else {
                    return .none
                }

                return .run { send in
                    await send(.addUserResponse(
                        await TaskResult {
                            try await apiClient.request(for: .chatEngine(.conversations(.conversation(id: conversationId.hexString, route: .joinuser))))
                        }
                    ))
                }

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
