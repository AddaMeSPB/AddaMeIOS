import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import MapKit
import ComposableCoreLocation
import AsyncImageLoder
import SwiftUIExtension
import ComposableArchitectureHelpers
import EventFormView
import EventDetailsView
import ChatView

extension EventView {
  public struct ViewState: Equatable {
    public var alert: AlertState<EventsAction>?
    public var isConnected = true
    public var isLocationAuthorized = false
    public var waitingForUpdateLocation = true
    public var isLoadingPage = false
    public var isMovingChatRoom: Bool = false
    public var location: Location?
    public var events: IdentifiedArrayOf<EventResponse.Item> = []
    public var myEvents: IdentifiedArrayOf<EventResponse.Item> = []
    public var event: EventResponse.Item?
    public var placeMark: CLPlacemark?

    public var eventFormState: EventFormState?
    public var eventDetailsState: EventDetailsState?
    public var isEventDetailsSheetPresented: Bool { self.eventDetailsState != nil }
    public var chatState: ChatState?
    public var conversation: ConversationResponse.Item?
  }

  public enum ViewAction: Equatable {
    case alertDismissed
    case dismissEventDetails

    case event(index: EventResponse.Item.ID, action: EventAction)

    case eventFormView(isNavigate: Bool)
    case eventForm(EventFormAction)

    case eventDetailsView(isPresented: Bool)
    case eventDetails(EventDetailsAction)

    case chatView(isNavigate: Bool)
    case chat(ChatAction)

    case currentLocationButtonTapped
    case eventTapped(EventResponse.Item)
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

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: EventsAction.view)
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
            if viewStore.waitingForUpdateLocation {
              VStack {
                ActivityIndicator()
                  .frame(maxWidth: .infinity)
                  .padding()
                  .padding(.top, 20)

                if viewStore.isLoadingPage {
                  Text("Now fetching near by Hanghouts!")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .animation(.easeOut)

                } else if viewStore.waitingForUpdateLocation {

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
        .background(colorScheme == .dark ? Color.gray.edgesIgnoringSafeArea(.all) : nil )

        HStack {
          Spacer()
          Button(action: { viewStore.send(.currentLocationButtonTapped) }) {
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
          .shadow(color: viewStore.state.isLocationAuthorized ? Color.green : Color.red, radius: 20, y: 5)
        }

      }
      .navigationBarTitleDisplayMode(.automatic)
      .toolbar {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
          toolbarItemTrailingButton(viewStore)
        }
      }
      .navigationTitle("Events")
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
      .sheet(isPresented:
        viewStore.binding(
          get: { $0.isEventDetailsSheetPresented },
          send: EventView.ViewAction.eventDetailsView(isPresented:)
        )
      ) {
        IfLetStore(
          self.store.scope(
            state: { $0.eventDetailsState },
            action: EventsAction.eventDetails
          ),
          then: EventDetailsView.init(store:)
        )
      }
    }
    .navigate(
      using: store.scope(
        state: \.eventFormState,
        action: EventsAction.eventForm
      ),
      destination: EventFormView.init(store:),
      onDismiss: {
        ViewStore(store.stateless).send(.eventFormView(isNavigate: false))
      }
    )
    .navigate(
      using: store.scope(
        state: \.chatState,
        action: EventsAction.chat
      ),
      destination: ChatView.init(store:),
      onDismiss: {
        ViewStore(store.stateless).send(.chatView(isNavigate: false))
      }
    )
  }

  private func toolbarItemTrailingButton(
    _ viewStore: ViewStore<EventView.ViewState, EventView.ViewAction>
  ) -> some View {
      Button(action: {
        viewStore.send(.eventFormView(isNavigate: true))
      }) {
        if #available(iOS 15.0, *) {
          Image(systemName: "plus.circle")
            .font(.title)
//            .foregroundColor(
//              viewStore.state.isLocationAuthorized ? Color.black : Color.gray
//            )
            .foregroundColor(colorScheme == .dark ? .white : .blue )
            .opacity(viewStore.isEventDetailsSheetPresented ? 0 : 1)
            .overlay {
              if viewStore.isEventDetailsSheetPresented {
                ProgressView()
                  .frame(width: 150.0, height: 150.0)
                  .padding(50.0)
              }
            }
        } else {
          Image(systemName: "plus.circle")
            .font(.title)
            .foregroundColor(viewStore.state.isLocationAuthorized ? Color.black : Color.gray)
        }
      }
      .disabled(viewStore.state.placeMark == nil)
      .opacity(viewStore.state.placeMark == nil ? 0 : 1)
  }
}

struct EventView_Previews: PreviewProvider {

  static let environment = EventsEnvironment(
    pathMonitorClient: .satisfied,
    locationManager: .live,
    eventClient: .happyPath,
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: EventsState.placeholderEvents,
    reducer: eventReducer,
    environment: environment
  )

  static var previews: some View {
//    TabView {
//      NavigationView {

//        EventView(store: store)
//          .redacted(reason: .placeholder)
//          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
          // .environment(\.colorScheme, .dark)
//      }
//    }
//
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
    WithViewStore(self.store) { viewStore in
      ForEachStore(
        self.store.scope(state: \.events, action: EventsAction.event)
      ) { eventStore in
        WithViewStore(eventStore) { eventViewStore in
          Button(action: {
            viewStore.send(.eventTapped(eventViewStore.state))
          }) {
            EventRowView(store: eventStore, currentLocation: viewStore.state.location)
              .onAppear {
                viewStore.send(.fetchMoreEventIfNeeded(item: eventViewStore.state) )
//                viewStore.send(.fetchMyEvents)
              }

          }
          .buttonStyle(PlainButtonStyle())
        }
      }
    }
  }
}

public struct EventRowView: View {

  let currentLocation: Location?
  @Environment(\.colorScheme) var colorScheme

  public let store: Store<EventResponse.Item, EventAction>

  public init(store: Store<EventResponse.Item, EventAction>, currentLocation: Location?) {
    self.currentLocation = currentLocation
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        if viewStore.imageUrl != nil {
          AsyncImage(
            urlString: viewStore.imageUrl,
            placeholder: { Text("Loading...").frame(width: 100, height: 100, alignment: .center) },
            image: {
              Image(uiImage: $0).resizable()
            }
          )
          .aspectRatio(contentMode: .fit)
          .frame(width: 120)
          .padding(.trailing, 15)
          .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
        } else {
          Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 90)
            .padding(10)
            .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
        }

        VStack(alignment: .leading) {
          Text(viewStore.name)
            .foregroundColor(colorScheme  == .dark ? Color.white : Color.black)
            .lineLimit(2)
            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
            .font(.system(size: 23, weight: .light, design: .rounded))
            .padding(.top, 10)
            .padding(.bottom, 5)

          Text(viewStore.addressName)
            .lineLimit(2)
            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
            .font(.system(size: 15, weight: .light, design: .rounded))
            .foregroundColor(.blue)
            .padding(.bottom, 5)

          Spacer()
          HStack {
            Spacer()
            Text("\(distance(location: viewStore.location)) away")
              .lineLimit(2)
              .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
              .font(.system(size: 15, weight: .light, design: .rounded))
              .foregroundColor(.blue)
              .padding(.bottom, 10)
          }
          .padding(.bottom, 5)

        }

        Spacer()
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(colorScheme == .dark ? Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) : Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)) )
      )
      .padding(10)
    }
  }

  func distance(location: CLLocation) -> String {
    guard let currentCoordinate = currentLocation?.rawValue else {
      print(#line, "Missing currentCoordinate")
      return "Loading Coordinate"
    }

    let distance = currentCoordinate.distance(from: location) / 1000
    return String(format: "%.02f km", distance)
  }
}
