import MapKit
import ComposableCoreLocation
import AddaSharedModels

// swiftlint:disable all
extension EventsState {

    public static let placeholderEvents = Self(
      isConnected: true,
      isLocationAuthorized: true,
      waitingForUpdateLocation: false,
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
      events: .init(uniqueElements: EventsResponse.draff.items)
    )
    
    public static let fetchEvents = Self(
      isConnected: true,
      isLocationAuthorized: true,
      waitingForUpdateLocation: true,
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
      events: .init(uniqueElements: EventsResponse.draff.items)
    )


    public static let eventForRow = Self(
      waitingForUpdateLocation: false,
      location: Location(
        altitude: 0,
        coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
        course: 0,
        horizontalAccuracy: 0,
        speed: 0,
        timestamp: Date(timeIntervalSince1970: 0),
        verticalAccuracy: 0
      ),
      event: EventResponse.exploreAreaDraff
    )
}
