import ComposableArchitecture
import CoreLocation
import ComposableCoreLocation
import MapKit
import AddaSharedModels

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension LocationManager: TestDependencyKey {
    public static let previewValue: Self = .live
    public static let testValue: Self = .failing
}

extension LocationManager: DependencyKey {
    public static let liveValue: Self = .live
}

extension DependencyValues {
    public var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

public struct LocationReducer: ReducerProtocol {

    public struct State: Equatable {

        public var alert: AlertState<Action>?
        public var coordinate: CLLocation?
        public var isLocationAuthorized = false
        public var waitingForUpdateLocation = false
        public var isRequestingCurrentLocation = false
        public var isConnected = false
        public var location: Location? = nil
        public var placeMark: Placemark? = nil

        public init(coordinate: CLLocation? = nil) {
            self.coordinate = coordinate
        }
    }

    public enum Action: Equatable {
        case callDelegateThenGetLocation
        case locationManager(LocationManager.Action)
        case delegate
        case getLocation
        case askLocationPermission
        case tearDown
        case placeMarkResponse(TaskResult<Placemark>)
    }

    @Dependency(\.locationManager) var locationManager
    @Dependency(\.mainQueue) var mainQueue

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {

        @Sendable func getPlacemark(_ location: Location) async throws -> Placemark {

            do {
                let address = CLGeocoder()
                let placemarks = try await address.reverseGeocodeLocation(location.rawValue)
                let new_placemark: MKPlacemark = MKPlacemark(placemark: placemarks[0])
                return Placemark(rawValue: new_placemark)
            } catch {
                throw("Placemark is empty")
            }
        }

        enum LocationManagerId {}

        switch action {
        case .callDelegateThenGetLocation:
            return .run { send in
                await send(.delegate)
                await send(.getLocation)
            }

        case let .locationManager(.didUpdateLocations(locations)):
            state.isRequestingCurrentLocation = false
            guard let location = locations.first else { return .none }
            state.location = location

            return .task {
                .placeMarkResponse(
                  await TaskResult {
                      try await getPlacemark(location)

                      //await send(.locationManager(.didEnterRegion() ))
                  }
                )
            }

        case let .locationManager(.didChangeAuthorization(clAuthorizationStatus)):
            if clAuthorizationStatus != .notDetermined {
                if clAuthorizationStatus == .denied || clAuthorizationStatus == .restricted {
                    state.alert = .init(
                        title: TextState(
                            """
                            Please note without location access we will not able to show any events.
                            To give us access to your location in settings.
                            """
                        )
                    )
                    return .none
                }
            }

            if clAuthorizationStatus == .authorizedAlways || clAuthorizationStatus == .authorizedWhenInUse {
                return .run { send in
                    await send(.getLocation)
                }
            }

            return .none
            
        case .locationManager:
            return .none

        case .delegate:
            return locationManager.delegate()
                .map(Action.locationManager)
                .cancellable(id: LocationManagerId.self)

        case .tearDown:
            return .cancel(id: LocationManagerId.self)

        case .askLocationPermission:
            #if os(macOS)
            return locationManager
                .requestAlwaysAuthorization()
                .fireAndForget()
            #else
            return locationManager
                .requestWhenInUseAuthorization()
                .fireAndForget()
            #endif

        case .getLocation:
            switch locationManager.authorizationStatus() {
            case .notDetermined:
                state.isRequestingCurrentLocation = true
                state.waitingForUpdateLocation = true

                #if os(macOS)
                return locationManager
                    .requestAlwaysAuthorization()
                    .fireAndForget()
                #else
                return locationManager
                    .requestWhenInUseAuthorization()
                    .fireAndForget()
                #endif

            case .restricted, .denied:
                state.isLocationAuthorized = false
                state.alert = .init(title: TextState("Please give us access to your location in settings."))
                return .none

            case .authorizedAlways, .authorizedWhenInUse:
                state.isLocationAuthorized = true
                state.isConnected = true
                state.waitingForUpdateLocation = false

                //  return locationManager.set(
                //      activityType: nil,//CLActivityType? = nil,
                //      allowsBackgroundLocationUpdates: true,
                //      desiredAccuracy: nil,//CLLocationAccuracy? = nil,
                //      distanceFilter: 20,//CLLocationDistance? = nil,
                //      headingFilter: nil,//CLLocationDegrees? = nil,
                //      headingOrientation: nil,// CLDeviceOrientation? = nil,
                //      pausesLocationUpdatesAutomatically: false,//Bool? = nil,
                //      showsBackgroundLocationIndicator: false //Bool? = nil
                //  )
                //  .fireAndForget()
                //  locationManager.startUpdatingLocation()
                //  locationManager.allowsBackgroundLocationUpdates = true
                //  locationManager.pausesLocationUpdatesAutomatically = false
                //  locationManager.desiredAccuracy = kCLLocationAccuracyBest
                //  locationManager.distanceFilter = 20.0 // 20.0 meters

                return locationManager
                    .startUpdatingLocation()
                    .fireAndForget()

            @unknown default:
                return .none
            }

        case let .placeMarkResponse(.success(placemarkNewValue)):
            state.placeMark = placemarkNewValue
            return .cancel(id: LocationManagerId.self)

        case .placeMarkResponse(.failure):
            // handle error
            return .none
        }
    }

}

