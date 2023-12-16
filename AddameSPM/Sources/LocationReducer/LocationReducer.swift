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

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}

extension LocationReducer.State {
    public static let diff = Self(
        coordinate: CLLocation(latitude: 60.020532228306031, longitude: 30.388014239849944),
        isLocationAuthorized: true
    )
}

public struct LocationReducer: Reducer {

    public struct ID: Hashable, @unchecked Sendable {
      let rawValue: AnyHashable

      init<RawValue: Hashable & Sendable>(_ rawValue: RawValue) {
        self.rawValue = rawValue
      }

      public init() {
        struct RawValue: Hashable, Sendable {}
        self.rawValue = RawValue()
      }
    }

    public struct State: Equatable {

        public var alert: AlertState<Action>?
        public var coordinate: CLLocation?
        public var isLocationAuthorized = false
        public var waitingForUpdateLocation = false
        public var isRequestingCurrentLocation = false
        public var isConnected = false
        public var location: Location? = nil
        public var placeMark: Placemark? = nil

        public init(
            alert: AlertState<LocationReducer.Action>? = nil,
            coordinate: CLLocation? = nil,
            isLocationAuthorized: Bool = false,
            waitingForUpdateLocation: Bool = false,
            isRequestingCurrentLocation: Bool = false,
            isConnected: Bool = false,
            location: Location? = nil,
            placeMark: Placemark? = nil
        ) {
            self.alert = alert
            self.coordinate = coordinate
            self.isLocationAuthorized = isLocationAuthorized
            self.waitingForUpdateLocation = waitingForUpdateLocation
            self.isRequestingCurrentLocation = isRequestingCurrentLocation
            self.isConnected = isConnected
            self.location = location
            self.placeMark = placeMark
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

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {

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
                
            return .run { send in
                await send(.placeMarkResponse(
                  await TaskResult {
                      try await getPlacemark(location)
                  }
                ))
            }

        case let .locationManager(.didChangeAuthorization(status)):
            switch status {
            case .notDetermined:
                    state.alert = .init(
                        title: TextState(
                            """
                            Please note without location access we will not able to show any events.
                            To give us access to your location in settings.
                            """
                        )
                    )
                return .none
            case .restricted, .denied:
                    state.isLocationAuthorized = false
                    state.alert = .init(
                        title: TextState(
                            """
                            Please note without location access we will not able to show any events.
                            To give us access to your location in settings.
                            """
                        )
                    )
                return .none
            case .authorizedAlways, .authorizedWhenInUse:
                state.isLocationAuthorized = true

                return .run { send in
                    await send(.getLocation)
                }
            @unknown default:
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
            
        case .locationManager:
            return .none

        case .delegate:
            return .publisher {
                locationManager
                    .delegate()
                    .map(LocationReducer.Action.locationManager)
            }
            .cancellable(id: LocationReducer.ID())


        case .tearDown:
            return .cancel(id: LocationReducer.ID())

        case .askLocationPermission:

            return .run { _ in
                #if os(macOS)
                try await locationManager.requestAlwaysAuthorization().async()
                #else
                try await locationManager.requestWhenInUseAuthorization().async()
                #endif
            }


        case .getLocation:
            switch locationManager.authorizationStatus() {
            case .notDetermined:
                state.isRequestingCurrentLocation = true
                state.waitingForUpdateLocation = true

                return .run { _ in
                    #if os(macOS)
                        try await locationManager.requestAlwaysAuthorization().async()
                    #else
                        try await locationManager.requestWhenInUseAuthorization().async()
                    #endif
                }

            case .restricted, .denied:
                state.isLocationAuthorized = false
                state.alert = .init(title: TextState("Please give us access to your location in settings."))
                return .none

            case .authorizedAlways, .authorizedWhenInUse:
                state.isLocationAuthorized = true
                state.isConnected = true
                state.waitingForUpdateLocation = false

                return .run { _ in
                    try await locationManager.startUpdatingLocation().async()
                }

            @unknown default:
                return .none
            }

        case let .placeMarkResponse(.success(placemarkNewValue)):
            state.placeMark = placemarkNewValue
                return .cancel(id: LocationReducer.ID())

        case .placeMarkResponse(.failure):
            // handle error
            return .none
        }
    }

}

