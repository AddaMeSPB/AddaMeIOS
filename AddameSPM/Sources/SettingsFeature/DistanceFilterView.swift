import ComposableArchitecture
import SwiftUI
import UserDefaultsClient

public enum DistanceType: String, Equatable {
    case kilometers, miles

    var intValue: Int {
        switch self {
        case .kilometers:
            return 0
        case .miles:
            return 1
        }
    }
}

extension DistanceType {
    func convertToMiles(kilometers: Double) -> Double {
        return kilometers * 0.621371
    }

    func convertToKilometers(miles: Double) -> Double {
        return miles * 1.60934
    }
}

public enum DistanceKey: String, Equatable {
    case distance, typee
}

extension Distance.State {
    public static let disState = Self(
        currentDistance: 250
    )
}

extension DistanceType {
    public static func fetchCurrentDistanceInMeters(userDefaults: UserDefaultsClient) -> Double {
        let defaultDistance = 250.0
        let kilometersToMeters = 1000.0
        let milesToMeters = 1609.0

        let distanceTypeInt = userDefaults.integerForKey(DistanceKey.typee.rawValue)
        let distanceType = distanceTypeInt == 0 ? DistanceType.kilometers : .miles
        let savedDistance = userDefaults.doubleForKey(DistanceKey.distance.rawValue)

        let distanceInMeters = savedDistance != 0.0
            ? (distanceType == .kilometers ? savedDistance * kilometersToMeters : savedDistance * milesToMeters)
            : defaultDistance * (distanceType == .kilometers ? kilometersToMeters : milesToMeters)

        return distanceInMeters
    }
}


extension Distance.State {
    public struct ViewState: Equatable {
        public var distanceTypeToggleisOn: Bool = true
        public var distanceType: DistanceType = .kilometers
        public var distanceValue: Double = 0.0
        public var distance: Double
        public var maxDistance: Double = 250.0
    }

    public enum ViewAction: Equatable {
        case onAppear
        case distanceTypeToggleChanged(Bool)
        case distance(_ value: Double)
    }
}

extension Distance.Action {
    static func view(_ localAction: DistanceFilterView.ViewAction) -> Self {
        switch localAction {
        case .onAppear:
            return onAppear
        case let .distanceTypeToggleChanged(boolean):
            return distanceTypeToggleChanged(boolean)
        case let .distance(value):
            return distance(value)
        }
    }
}

extension DistanceFilterView {
    public struct ViewState: Equatable {
        public init(state: Distance.State) {
            self.distanceTypeToggleisOn = state.distanceTypeToggleisOn
            self.distanceType = state.distanceType
            self.currentDistance = state.currentDistance
            self.minDistance = state.minDistance
            self.maxDistance = state.maxDistance
        }

        public var distanceTypeToggleisOn: Bool = true
        public var distanceType: DistanceType = .kilometers
        public var currentDistance: Double
        public var minDistance: Double = 5.0
        public var maxDistance: Double = 250.0
    }

    public enum ViewAction: Equatable {
        case onAppear
        case distanceTypeToggleChanged(Bool)
        case distance(_ value: Double)
    }
}

public struct Distance: Reducer {

    public enum Action: Equatable {
        case onAppear
        case distanceTypeToggleChanged(Bool)
        case distance(_ value: Double)
    }

    public struct State: Equatable {
        public init(
            distanceTypeToggleisOn: Bool = true,
            distanceType: DistanceType = .kilometers,
            currentDistance: Double = 0.0,
            minDistance: Double = 5.0,
            maxDistance: Double = 250.0
        ) {
            self.distanceTypeToggleisOn = distanceTypeToggleisOn
            self.distanceType = distanceType
            self.currentDistance = currentDistance
            self.minDistance = minDistance
            self.maxDistance = maxDistance
        }

        public var distanceTypeToggleisOn: Bool = true
        public var distanceType: DistanceType = .kilometers
        public var currentDistance: Double
        public var minDistance: Double = 5.0
        public var maxDistance: Double = 250.0

    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            let distanceTypeIntValue = userDefaults.integerForKey(DistanceKey.typee.rawValue)
            let distanceType = distanceTypeIntValue == 0 ? DistanceType.kilometers : .miles
            state.distanceType = distanceType
            state.distanceTypeToggleisOn = distanceType == .kilometers

            let savedDistance = userDefaults.doubleForKey(DistanceKey.distance.rawValue)
            state.currentDistance = savedDistance != 0 ? savedDistance : 250
            state.maxDistance = distanceType == .kilometers ? 250 : distanceType.convertToMiles(kilometers: 250)

            return .none

        case let .distanceTypeToggleChanged(value):

            let newDistanceType = value ? DistanceType.kilometers : .miles
            state.distanceTypeToggleisOn = value
            state.distanceType = newDistanceType

            let distanceIntValue = value ? 0 : 1

            // Convert current distance to the new unit
            if newDistanceType == .kilometers {
                state.currentDistance = DistanceType.miles.convertToKilometers(miles: state.currentDistance)
            } else {
                state.currentDistance = DistanceType.kilometers.convertToMiles(kilometers: state.currentDistance)
            }
            state.maxDistance = newDistanceType == .kilometers ? 250 : newDistanceType.convertToMiles(kilometers: 250)

            return .run { [currentDistance = state.currentDistance] _ in
                await userDefaults.setDouble(
                    currentDistance,
                    DistanceKey.distance.rawValue
                )

                await userDefaults.setInteger(
                    distanceIntValue,
                    DistanceKey.typee.rawValue
                )

            }

        case let .distance(value):

            state.currentDistance = value
            let distanceValueAfterSet = value

            return .run { _ in
                await userDefaults.setDouble(
                    distanceValueAfterSet,
                    DistanceKey.distance.rawValue
                )
            }
        }
    }
}

public struct DistanceFilterView: View {
    let store: StoreOf<Distance>

    public init(store: StoreOf<Distance>) {
        self.store = store
    }

    // WithViewStore(self.store, observe: ViewState.init, send: Hangouts.Action.init)
    public var body: some View {
        WithViewStore(
            self.store,
            observe: ViewState.init, send: Distance.Action.view
        ) { viewStore in

            VStack(alignment: .leading) {
                Toggle(
                    isOn:
                        viewStore.binding(
                            get: \.distanceTypeToggleisOn,
                            send: ViewAction.distanceTypeToggleChanged
                        )
                ) {
                    Text("\(viewStore.distanceType.rawValue.capitalized) : \(Int(viewStore.maxDistance))")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(.green)
                }
                .padding(.vertical)

                Text("Near by distance \(Int(viewStore.currentDistance))")
                    .font(.title3)
                    .bold()
                    .font(.system(.headline, design: .rounded))

                HStack {

                    Slider(
                        value: viewStore.binding(
                            get: \.currentDistance,
                            send: ViewAction.distance
                        ),
                        in: viewStore.distanceType == .kilometers ? 5...250 : 5...DistanceType.kilometers.convertToMiles(kilometers: 250)
                    )
                    .accentColor(.green)

                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct DistanceFilterView_Previews: PreviewProvider {

    static let store = Store(
        initialState: Distance.State.disState
    ) {
        Distance()
    }

    static var previews: some View {
        DistanceFilterView(store: store)
    }
}
