import SwiftUI
import Foundation
import ComposableArchitecture
import ChatView
import ComposableArchitectureHelpers
import ComposableCoreLocation
import HangoutDetailsFeature
import EventFormView
import MapKit
import AddaSharedModels

import SwiftUIExtension
import AdSupport
import AppTrackingTransparency
import LocationReducer
import SwiftUIHelpers

extension HangoutsView {
    public struct ViewState: Equatable {
        init(state: Hangouts.State) {

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
            self.isHangoutDetailsSheetPresented = state.isHangoutDetailsSheetPresented
            self.locationState = state.locationState
        }

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
        public var isHangoutDetailsSheetPresented: Bool
        public var locationState: LocationReducer.State
        //        public var eventDetailsState: HangoutDetailsState?
        //        public var isHangoutDetailsSheetPresented: Bool { eventDetailsState != nil }
        //        public var chatState: ChatState?
        //        public var conversation: ConversationOutPut?


    }

    public enum ViewAction: Equatable {
        case alertDismissed
        case dismissHangoutDetails

        case event(index: EventResponse.ID, action: EventRowReducer.Action)

        case fetchEventOnAppear
        case hangoutFormView(isNavigate: Bool)
        case hangoutForm(HangoutForm.Action)

        case hangoutDetailsSheet(isPresented: Bool)
        case hangoutDetails(HangoutDetails.Action)

        case chatView(isNavigate: Bool)
        case chat(Chat.Action)

        case fetchMoreEventsIfNeeded(item: EventResponse?)

        case currentLocationButtonTapped
        case eventTapped(EventResponse)

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
                    .animation(.easeOut, value: 0.3)
                    .layoutPriority(1)
            }

            if viewStore.locationState.waitingForUpdateLocation {
                Text("Please wait we are updating your current location!")
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
                    .animation(.easeIn, value: 0.3)
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
                .animation(.easeIn, value: 0.3)

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

        WithViewStore(self.store, observe: ViewState.init,  send: Hangouts.Action.init) { viewStore in
            GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
//                VStack {
//                    if viewStore.isHangoutDetailsSheetPresented
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

                            ForEachStore(
                                self.store.scope(state: \.events, action: Hangouts.Action.event)
                            ) { eventStore in
                                WithViewStore(eventStore, observe: { $0 }) { eventViewStore in
                                    Button {
                                        viewStore.send(.eventTapped(eventViewStore.state))
                                    } label: {
                                        EventRowView(
                                            store: eventStore,
                                            currentLocation: viewStore.state.locationState.location,
                                            geo: geo
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        if viewStore.events.isLastItem(eventViewStore.state) {
                                            viewStore.send(.fetchMoreEventsIfNeeded(item: eventViewStore.state))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Hangouts")
                .background(colorScheme == .dark ? Color.gray.edgesIgnoringSafeArea(.all) : nil)

            }
            .onDisappear { viewStore.send(.onDisAppear) }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    toolbarItemTrailingButton(viewStore)
                }
            }
            .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
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
            .background(
                NavigationLink(
                  destination: IfLetStore(
                    self.store.scope(
                      state: \.chatState,
                      action: Hangouts.Action.chat
                    )
                  ) {
                      ChatView(store: $0)
                  },
                  isActive: viewStore.binding(
                    get: \.isMovingChatRoom,
                    send: { .chatView(isNavigate: $0) }
                  )
                ) {}
            )
            .sheet(
              isPresented: viewStore.binding(
                get: \.isHangoutDetailsSheetPresented,
                send: { .hangoutDetailsSheet(isPresented: $0) }
              )
            ) {
              IfLetStore(
                self.store.scope(
                  state: \.hangoutDetailsState,
                  action: Hangouts.Action.hangoutDetails
                )
              ) {
                HangoutDetailsView(store: $0)
              } else: {
                ProgressView()
              }
            }
        }
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
        initialState: Hangouts.State(
            isLoadingPage: false, isIDFAAuthorized: true,
            location: Location(
                altitude: 0,
                coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
                course: 0,
                horizontalAccuracy: 0,
                speed: 0,
                timestamp: Date(timeIntervalSince1970: 0),
                verticalAccuracy: 0
            ),
            events: .init(uniqueElements: EventsResponse.draff.items),
            locationState: LocationReducer.State.diff,
            websocketState: .init(user: .withFirstName)
        )
    ) {
        Hangouts()
    }

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
        WithViewStore(self.store, observe: HangoutsView.ViewState.init, send: Hangouts.Action.init) { viewStore in
            GeometryReader { geo in

                ForEachStore(
                    self.store.scope(state: \.events, action: Hangouts.Action.event)
                ) { eventStore in
                    WithViewStore(eventStore, observe: { $0 }) { eventViewStore in
                        Button {
                            viewStore.send(.eventTapped(eventViewStore.state))
                        } label: {
                            EventRowView(
                                store: eventStore,
                                currentLocation: viewStore.state.locationState.location,
                                geo: geo
                            )
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
}


extension IdentifiedArrayOf where Element: Identifiable {
    func isLastItem(_ item: Element) -> Bool {
        self.last?.id == item.id
    }
}
