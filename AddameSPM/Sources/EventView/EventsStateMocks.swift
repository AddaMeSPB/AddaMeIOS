 import MapKit
 import ComposableCoreLocation
 import AddaSharedModels

// swiftlint:disable all
extension Hangouts.State {

    public static let placeholderEvents = Self(
      isConnected: true,
      isLoadingPage: true,
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
      websocketState: .init(user: .withFirstName)
    )

    public static let fetchEvents = Self(
      isConnected: true,
      isLoadingPage: false,
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
      websocketState: .init(user: .withFirstName)
    )


    public static let eventForRow = Self(
      location: Location(
        altitude: 0,
        coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
        course: 0,
        horizontalAccuracy: 0,
        speed: 0,
        timestamp: Date(timeIntervalSince1970: 0),
        verticalAccuracy: 0
      ),
      event: EventResponse.exploreAreaDraff,
      websocketState: .init(user: .withFirstName)
    )
 }
