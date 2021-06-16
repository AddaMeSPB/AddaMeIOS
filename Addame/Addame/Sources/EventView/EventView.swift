import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import MapKit
import ComposableCoreLocation
import AsyncImageLoder
import SwiftUIExtension
import EventForm
import ComposableArchitectureHelpers

extension EventView {
  public struct ViewState: Equatable {
    public var alert: AlertState<EventsAction>?
    public var isConnected = true
    public var isLocationAuthorized = false
    public var waitingForUpdateLocation = true
    public var fetchAddress = ""
    public var location: Location?
    public var events: [EventResponse.Item] = []
    public var myEvents: [EventResponse.Item] = []
    public var eventDetails: EventResponse.Item?
    public var isLoadingPage = false

    public var eventFormState: EventFormState?
  }

  public enum ViewAction: Equatable {
    case alertDismissed
    case dismissEventDetails
    case presentEventForm(Bool)
    case eventForm(EventFormAction)
    case event(index: Int, action: EventAction)

    case fetchMoreEventIfNeeded(item: EventResponse.Item?)
    case fetchMyEvents
    case fetachAddressFromCLLocation(_ cllocation: CLLocation? = nil)
    case addressResponse(Result<String, Never>)

    case currentLocationButtonTapped
    case locationManager(LocationManager.Action)
    case eventsResponse(Result<EventResponse, HTTPError>)
    case myEventsResponse(Result<EventResponse, HTTPError>)
    case eventTapped(EventResponse.Item)

    case popupSettings
    case dismissEvent
    case onAppear
  }
}

public struct EventView: View {

  public init(store: Store<EventsState, EventsAction>) {
    self.store = store
  }

  public let store: Store<EventsState, EventsAction>

  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: EventsAction.view)) { viewStore in

      ZStack(alignment: .bottom) {

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
      .sheet(
        item: viewStore.binding(get: \.eventDetails, send: .dismissEventDetails)
      ) { event in
        EventDetailsView(event: event)
      }
      .navigationBarTitleDisplayMode(.automatic)
      .toolbar {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
          return Button(action: {
            viewStore.send(.presentEventForm(true))
          }) {
            Image(systemName: "plus.circle")
              .font(.title)
              .foregroundColor(viewStore.state.isLocationAuthorized ? Color.black : Color.gray)
          }
        }
      }
      .navigationTitle("Events")
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
    }
    .navigate(
      using: store.scope(
        state: \.eventFormState,
        action: EventsAction.eventForm
      ),
      destination: EventFormView.init(store:),
      onDismiss: {
        ViewStore(store.stateless).send(.presentEventForm(false))
      }
    )
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
    TabView {
      NavigationView {

        EventView(store: store)
//          .redacted(reason: .placeholder)
//          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
          .environment(\.colorScheme, .dark)
      }
    }
//
//    Group {
//      TabView {
//        NavigationView {
//          EventView(store: store)
//  //          .redacted(reason: .placeholder)
//        }
//      }
//      TabView {
//        NavigationView {
//          EventView(store: store)
//  //          .redacted(reason: .placeholder)
//            .environment(\.colorScheme, .dark)
//        }
//      }
//    }
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
          Button(action: { viewStore.send(.eventTapped(eventViewStore.state)) }) {
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
