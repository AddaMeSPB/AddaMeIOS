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

public struct Hangouts: ReducerProtocol {

    public struct State: Equatable {
        public init(
            alert: AlertState<Hangouts.Action>? = nil,
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

        public var alert: AlertState<Hangouts.Action>?
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
            return .run { send in
                try await self.mainQueue.sleep(for: .seconds(0.3))
                await send(.chatView(isNavigate: true))
            }
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
        case .locationManager:
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
        case .addUserResponse(.success):
            return .run { send in
                await send(.hangoutDetails(.startChat(true)))
            }
        case .addUserResponse(.failure):
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

                guard let conversationId = state.event?.conversationsId else {
                    return .none
                }

                return .task {
                    .addUserResponse(
                        await TaskResult {
                            try await apiClient.request(for: .chatEngine(.conversations(.conversation(id: conversationId.hexString, route: .joinuser))))
                        }
                    )
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
