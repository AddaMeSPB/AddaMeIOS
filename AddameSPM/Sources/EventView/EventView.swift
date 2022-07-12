import AsyncImageLoder
import ChatView
import ComposableArchitecture
import ComposableArchitectureHelpers
import ComposableCoreLocation
import ComposablePresentation
import EventDetailsView
import EventFormView
import HTTPRequestKit
import MapKit
import SharedModels
import SwiftUI
import SwiftUIExtension
import AdSupport
import AppTrackingTransparency
import MyEventsView

extension EventView {
  public struct ViewState: Equatable {
    public var alert: AlertState<EventsAction>?
    public var isConnected = true
    public var isLocationAuthorized = false
    public var waitingForUpdateLocation = true
    public var isLoadingPage = false
    public var isLoadingMyEvent: Bool = false
    public var isMovingChatRoom: Bool = false
    public var isEFromNavigationActive: Bool = false
    public var isIDFAAuthorized = false
    public var location: Location?
    public var events: IdentifiedArrayOf<EventResponse.Item> = []
    public var myEvent: EventResponse.Item?
    public var event: EventResponse.Item?
    public var placeMark: CLPlacemark?

    public var eventFormState: EventFormState?
    public var eventDetailsState: EventDetailsState?
    public var isEventDetailsSheetPresented: Bool { eventDetailsState != nil }
    public var chatState: ChatState?
    public var conversation: ConversationResponse.Item?
  }

  public enum ViewAction: Equatable {
    case alertDismissed
    case dismissEventDetails

    case event(index: EventResponse.Item.ID, action: EventAction)

    case fetchEventOnAppear
    case eventFormView(isNavigate: Bool)
    case eventForm(EventFormAction)
    case myEventAction(MyEventAction)

    case eventDetailsView(isPresented: Bool)
    case eventDetails(EventDetailsAction)

    case chatView(isNavigate: Bool)
    case chat(ChatAction)

    case fetchMoreEventsIfNeeded(item: EventResponse.Item?)

    case currentLocationButtonTapped
    case eventTapped(EventResponse.Item)

    case idfaAuthorizationStatus(ATTrackingManager.AuthorizationStatus)
    case popupSettings
    case dismissEvent
    case onAppear
  }
}

public struct EventView: View {
  @Environment(\.colorScheme) var colorScheme

  public init(store: Store<EventsState, EventsAction>) {
    self.store = store
  }

  public let store: Store<EventsState, EventsAction>

    public func locationAndLoadingStatus(
        viewStore: ViewStore<EventView.ViewState, EventView.ViewAction>
    ) -> some View {

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

                if viewStore.waitingForUpdateLocation {
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

    public func isLocationAuthorizedView(
        viewStore: ViewStore<EventView.ViewState, EventView.ViewAction>
    ) -> some View {

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
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: EventsAction.view
      )
    ) { viewStore in

      ZStack(alignment: .bottomTrailing) {
        VStack {
          if viewStore.isEventDetailsSheetPresented && viewStore.isMovingChatRoom {
            ProgressView()
              .frame(width: 150.0, height: 150.0)
              .padding(50.0)
          }
        }

        ScrollView {
          LazyVStack {

              if viewStore.waitingForUpdateLocation { locationAndLoadingStatus(viewStore: viewStore) }
              if !viewStore.isLocationAuthorized { isLocationAuthorizedView(viewStore: viewStore) }

//              MyEventRowView(
//                store: Store(initialState: viewStore.myEvent, reducer: .empty, environment: ())
//              )

            EventsListView(
              store: viewStore.isLoadingPage
                ? Store(
                  initialState: EventsState.placeholderEvents,
                  reducer: .empty,
                  environment: ()
                )
                : self.store
            )
            .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
          }
        }
        .navigationTitle("Events")
        .background(colorScheme == .dark ? Color.gray.edgesIgnoringSafeArea(.all) : nil)

        HStack {
          Spacer()
          Button {
            viewStore.send(.currentLocationButtonTapped)
          } label: {
            Image(systemName: viewStore.state.isLocationAuthorized ? "circle" : "location")
              .foregroundColor(Color.white)
              .frame(
                width: viewStore.state.isLocationAuthorized ? 20 : 60,
                height: viewStore.state.isLocationAuthorized ? 20 : 60
              )
              .background(viewStore.state.isLocationAuthorized ? Color.green : Color.red)
              .clipShape(Circle())
              .padding([.trailing], 26)
              .padding([.bottom], 26)
          }
          .animation(.easeIn)
          .shadow(
            color: viewStore.state.isLocationAuthorized ? Color.green : Color.red, radius: 20, y: 5)
        }
      }
      .onAppear {
        ViewStore(store.stateless).send(.onAppear)
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .navigationBarTitleDisplayMode(.automatic)
      .toolbar {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
          toolbarItemTrailingButton(viewStore)
        }
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
    }
    .sheet(
      store.scope(state: \.eventDetailsState, action: EventsAction.eventDetails),
      mapState: replayNonNil(),
      onDismiss: {
        ViewStore(store.stateless).send(.eventDetailsView(isPresented: false))
      },
      content: EventDetailsView.init(store:)
    )
    .sheet(
      store.scope(state: \.eventFormState, action: EventsAction.eventForm),
      mapState: replayNonNil(),
      onDismiss: { ViewStore(store.stateless).send(.eventFormView(isNavigate: false)) },
      content: EventFormView.init(store:)
    )
//    .navigationLink(
//      store.scope(state: \.eventFormState, action: EventsAction.eventForm),
//      state: replayNonNil(),
//      onDismiss: {
//        ViewStore(store.stateless).send(.eventFormView(isNavigate: false))
//      },
//      destination: EventFormView.init(store:)
//    )
    .background(
      NavigationLinkWithStore(
        store.scope(state: \.chatState, action: EventsAction.chat),
        mapState: replayNonNil(),
        onDeactivate: { ViewStore(store.stateless).send(.chatView(isNavigate: false)) },
        destination: ChatView.init(store:)
      )
    )
  }

  private func toolbarItemTrailingButton(
    _ viewStore: ViewStore<EventView.ViewState, EventView.ViewAction>
  ) -> some View {
    Button {
      viewStore.send(.eventFormView(isNavigate: true))
    } label: {
      if #available(iOS 15.0, *) {
        Image(systemName: "plus.circle")
          .font(.title)
          .foregroundColor(colorScheme == .dark ? .white : .blue)
          .opacity(viewStore.isEventDetailsSheetPresented ? 0 : 1)
          .overlay(
            ProgressView()
              .frame(width: 150.0, height: 150.0)
              .padding(50.0)
              .opacity(viewStore.isEventDetailsSheetPresented ? 1 : 0)
          )
      } else {
        Image(systemName: "plus.circle")
          .font(.title)
          .foregroundColor(viewStore.state.isLocationAuthorized ? Color.black : Color.gray)
      }
    }
    .disabled(viewStore.state.placeMark == nil )
    .opacity(viewStore.state.placeMark == nil ? 0 : 1)
  }
}

struct EventView_Previews: PreviewProvider {

  static let store = Store(
    initialState: EventsState.fetchEvents,
    reducer: eventsReducer,
    environment: EventsEnvironment.happyPath
  )

  static var previews: some View {
    Group {
      TabView {
        NavigationView {
          EventView(store: store)
        }
      }

      TabView {
        NavigationView {
          EventView(store: store)
            .environment(\.colorScheme, .dark)
        }
      }
      .environment(\.colorScheme, .dark)
    }
  }
}

struct EventsListView: View {
  let store: Store<EventsState, EventsAction>

  var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: EventsAction.view
      )
    ) { viewStore in
      ForEachStore(
        self.store.scope(state: \.events, action: EventsAction.event)
      ) { eventStore in
        WithViewStore(eventStore) { eventViewStore in
          Button {
            viewStore.send(.eventTapped(eventViewStore.state))
          } label: {
            EventRowView(store: eventStore, currentLocation: viewStore.state.location)
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
