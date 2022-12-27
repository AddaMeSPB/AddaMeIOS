import SwiftUI
import Foundation
import ComposableArchitecture
import AsyncImageLoder
import ChatView
import ComposableArchitectureHelpers
import ComposableCoreLocation
import EventDetailsView
import EventFormView
import MapKit
import AddaSharedModels

import SwiftUIExtension
import AdSupport
import AppTrackingTransparency
import LocationReducer
import SwiftUIHelpers

//public struct HangoutsView: View {
//    @Environment(\.colorScheme) var colorScheme
//
//    public init(store: StoreOf<Hangouts>) {
//        self.store = store
//    }
//
//    public let store: StoreOf<Hangouts>
//
//    public var body: some View {
//        WithViewStore(
//            self.store.scope(
//                state: { $0.view },
//                action: Hangouts.Action.view
//            )
//        ) { viewStore in
//            VStack {
//                if let coordinate = viewStore.locationState.coordinate {
//                    Text("Location: \(coordinate.coordinate.longitude), \(coordinate.coordinate.latitude)")
//                }
//            }
//            .navigationTitle("Hangouts")
//            .background(colorScheme == .dark ? Color.gray.edgesIgnoringSafeArea(.all) : nil)
//        }
//
//    }
//
//}

extension HangoutsView {
    public struct ViewState: Equatable {
        init(state: Hangouts.State) {
            self.alert = state.alert
            self.isConnected = state.isConnected
            self.isLoadingPage = state.isLoadingPage
            self.isLoadingMyEvent = state.isLoadingMyEvent
            self.isMovingChatRoom = state.isMovingChatRoom
            self.isEFromNavigationActive = state.isEFromNavigationActive
            self.isIDFAAuthorized = state.isIDFAAuthorized
            self.isLocationAuthorizedCount = state.isLocationAuthorizedCount
            self.events = state.events
            self.myEvent = state.myEvent
            self.event = state.event
            self.hangoutFormState = state.hangoutFormState
            self.isHangoutNavigationActive = state.hangoutFormState != nil
            self.locationState = state.locationState
        }

        public var alert: AlertState<Hangouts.Action>?
        public var isConnected: Bool
        public var isLoadingPage: Bool
        public var isLoadingMyEvent: Bool
        public var isMovingChatRoom: Bool
        public var isEFromNavigationActive: Bool
        public var isIDFAAuthorized: Bool
        public var isLocationAuthorizedCount: Int
        public var events: IdentifiedArrayOf<EventResponse>
        public var myEvent: EventResponse?
        public var event: EventResponse?

        public var hangoutFormState: HangoutForm.State?
        public var isHangoutNavigationActive: Bool
        public var locationState: LocationReducer.State
        //        public var eventDetailsState: EventDetailsState?
        //        public var isEventDetailsSheetPresented: Bool { eventDetailsState != nil }
        //        public var chatState: ChatState?
        //        public var conversation: ConversationOutPut?


    }

    public enum ViewAction: Equatable {
        case alertDismissed
        case dismissEventDetails

        case event(index: EventResponse.ID, action: EventAction)

        case fetchEventOnAppear
        case hangoutFormView(isNavigate: Bool)
        case hangoutForm(HangoutForm.Action)

        case eventDetailsView(isPresented: Bool)
        //        case eventDetails(EventDetailsAction)

        case chatView(isNavigate: Bool)
        case chat(ChatAction)

        case fetchMoreEventsIfNeeded(item: EventResponse?)

        case currentLocationButtonTapped
        case eventTapped(EventResponse)

//        case idfaAuthorizationStatus(ATTrackingManager.AuthorizationStatus)
        case popupSettings
        case dismissEvent
        case onAppear
        case onDisAppear
    }
}


public struct HangoutsView: View {
    @Environment(\.colorScheme) var colorScheme

    public let store: StoreOf<Hangouts>

    public init(store: StoreOf<Hangouts>) {
        self.store = store
    }

    public func locationAndLoadingStatus(viewStore: ViewStore<HangoutsView.ViewState, HangoutsView.ViewAction>) -> some View {

        return HStack {
            ActivityIndicator()
                .padding(.leading, 5)

            if viewStore.isLoadingPage {
                Text("Now fetching near by Hanghouts!")
                    .font(.system(.body, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .animation(.easeOut)
                    .layoutPriority(1)
            }

            if viewStore.locationState.waitingForUpdateLocation {
                Text("Please wait we are updating your current location!")
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
                    .animation(.easeIn)
            }
        }
        .background(Color.red)
        .cornerRadius(25)
        .padding()

    }

    public func isLocationAuthorizedView(viewStore: ViewStore<HangoutsView.ViewState, HangoutsView.ViewAction>) -> some View {

        return VStack {
            Text("""
                  This feature does not work with get your current location so active it to see this feature,
                  You can change your permission anytime from app settings.
                  """
            ).font(.body)
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.bottom, 10)
                .animation(.easeIn)

            Button {
                viewStore.send(.popupSettings)
            } label: {
                Label("Go to settings", systemImage: "gear")
                    .padding(10.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(lineWidth: 2.0)
                    )
                    .foregroundColor(.red)
            }

        }

    }

    public var body: some View {

        WithViewStore(self.store, observe: ViewState.init, send: Hangouts.Action.init) { viewStore in

            ZStack(alignment: .bottomTrailing) {
//                VStack {
//                    if viewStore.isEventDetailsSheetPresented
//                        && viewStore.isMovingChatRoom {
//                        ProgressView()
//                            .frame(width: 150.0, height: 150.0)
//                            .padding(50.0)
//                    }
//                }

                ScrollView {
                    LazyVStack {

                        if viewStore.locationState.waitingForUpdateLocation {
                            locationAndLoadingStatus(viewStore: viewStore)
                        }

                        if !viewStore.locationState.isLocationAuthorized {
                            isLocationAuthorizedView(viewStore: viewStore)
                        }

                        EventsListView(
                            store: viewStore.isLoadingPage
                            ? Store(
                                initialState: Hangouts.State.placeholderEvents,
                                reducer: Hangouts()
                            )
                            : self.store
                        )
                        .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
                    }
                }
                .navigationTitle("Hangouts")
                .background(colorScheme == .dark ? Color.gray.edgesIgnoringSafeArea(.all) : nil)

//                HStack {
//                    Spacer()
//                    Button {
//                        viewStore.send(.currentLocationButtonTapped)
//                    } label: {
//                        Image(systemName: viewStore.state.isLocationAuthorized ? "circle" : "location")
//                            .foregroundColor(Color.white)
//                            .frame(
//                                width: viewStore.state.isLocationAuthorized ? 20 : 60,
//                                height: viewStore.state.isLocationAuthorized ? 20 : 60
//                            )
//                            .background(viewStore.state.isLocationAuthorized ? Color.green : Color.red)
//                            .clipShape(Circle())
//                            .padding([.trailing], 26)
//                            .padding([.bottom], 26)
//                    }
//                    .animation(.easeIn)
//                    .shadow(
//                        color: viewStore.state.isLocationAuthorized ? Color.green : Color.red, radius: 20, y: 5)
//                }
            }
            .onDisappear { viewStore.send(.onDisAppear) }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    toolbarItemTrailingButton(viewStore)
                }
            }
            .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
            .background(
                NavigationLink(
                  destination: IfLetStore(
                    self.store.scope(
                      state: \.hangoutFormState,
                      action: Hangouts.Action.hangoutForm
                    )
                  ) {
                      EventFormView(store: $0)
                  },
                  isActive: viewStore.binding(
                    get: \.isHangoutNavigationActive,
                    send: { .hangoutFormView(isNavigate: $0) }
                  )
                ) {}
            )
        }
//        .sheet(
//            store.scope(state: \.eventDetailsState, action: Hangouts.Action.eventDetails),
//            mapState: replayNonNil(),
//            onDismiss: {
//                ViewStore(store.stateless).send(.eventDetailsView(isPresented: false))
//            },
//            content: EventDetailsView.init(store:)
//        )
//        .sheet(
//            store.scope(state: \.eventFormState, action: Hangouts.Action.eventForm),
//            mapState: replayNonNil(),
//            onDismiss: { ViewStore(store.stateless).send(.eventFormView(isNavigate: false)) },
//            content: EventFormView.init(store:)
//        )
        //    .navigationLink(
        //      store.scope(state: \.eventFormState, action: EventsAction.eventForm),
        //      state: replayNonNil(),
        //      onDismiss: {
        //        ViewStore(store.stateless).send(.eventFormView(isNavigate: false))
        //      },
        //      destination: EventFormView.init(store:)
        //    )
//        .background(
//            NavigationLinkWithStore(
//                store.scope(state: \.chatState, action: Hangouts.Action.chat),
//                mapState: replayNonNil(),
//                onDeactivate: { ViewStore(store.stateless).send(.chatView(isNavigate: false)) },
//                destination: ChatView.init(store:)
//            )
//        )
    }

    private func toolbarItemTrailingButton(_ viewStore: ViewStore<HangoutsView.ViewState, HangoutsView.ViewAction>) -> some View {
        Button {
            viewStore.send(.hangoutFormView(isNavigate: true))
        } label: {
            if #available(iOS 15.0, *) {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(colorScheme == .dark ? .white : .blue)
//                    .opacity(viewStore.isEventDetailsSheetPresented ? 0 : 1)
//                    .overlay(
//                        ProgressView()
//                            .frame(width: 150.0, height: 150.0)
//                            .padding(50.0)
//                            .opacity(viewStore.isEventDetailsSheetPresented ? 1 : 0)
//                    )
            } else {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(viewStore.state.locationState.isLocationAuthorized ? Color.black : Color.gray)
            }
        }
        .disabled(viewStore.state.locationState.placeMark == nil )
        .opacity(viewStore.state.locationState.placeMark == nil ? 0 : 1)
    }
}

struct HangoutsView_Previews: PreviewProvider {

    static let store = Store(
        initialState: Hangouts.State(),
        reducer: Hangouts()
    )

    static var previews: some View {
        TabView {
            NavigationView {
                HangoutsView(store: store)
            }
        }
    }
}

struct EventsListView: View {
    let store: StoreOf<Hangouts>

    var body: some View {
//        WithViewStore(
//            self.store.scope(
//                state: { $0.view },
//                action: Hangouts.Action.view
//            )
//        )

        WithViewStore(self.store, observe: HangoutsView.ViewState.init, send: Hangouts.Action.init) { viewStore in
            ForEachStore(
                self.store.scope(state: \.events, action: Hangouts.Action.event)
            ) { eventStore in
                WithViewStore(eventStore) { eventViewStore in
                    Button {
                        viewStore.send(.eventTapped(eventViewStore.state))
                    } label: {
                        EventRowView(store: eventStore, currentLocation: viewStore.state.locationState.location)
                            .onAppear {
                                viewStore.send(.fetchMoreEventsIfNeeded(item: eventViewStore.state))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
