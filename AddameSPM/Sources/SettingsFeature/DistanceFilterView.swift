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

public enum DistanceKey: String, Equatable {
    case distance, typee
}

extension Distance.State {
    public static let disState = Self(
        currentDistance: 250
    )
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

public struct Distance: ReducerProtocol {

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

    public var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            let distanceTypeIntValue = userDefaults.integerForKey(DistanceKey.typee.rawValue)
            state.distanceTypeToggleisOn = distanceTypeIntValue == 0 ? true : false
            state.distanceType = distanceTypeIntValue == 0 ? .kilometers : .miles
            state.maxDistance = distanceTypeIntValue == 0 ? 250 : (250 * 1.609)
            state.currentDistance = userDefaults.doubleForKey(DistanceKey.distance.rawValue)

            return .none

        case let .distanceTypeToggleChanged(value):

            state.distanceTypeToggleisOn = value
            state.distanceType = value == true ? .kilometers : .miles
            state.maxDistance = value == true ? 250 : (250 * 1.609)

            let distanceIntValue = value == true ? 0 : 1

            switch state.distanceType {
            case .kilometers:
                state.currentDistance = 250
            case .miles:
                state.currentDistance = 402
            }

            return .run { _ in
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
                        in: 10...viewStore.maxDistance
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
    static let env = DistanceEnvironment(
        mainQueue: .immediate,
        userDefaults: .noop
    )

    static let store = Store(
        initialState: Distance.State.disState,
        reducer: Distance()
    )

    static var previews: some View {
        DistanceFilterView(store: store)
    }
}

public struct DistanceEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDefaults: UserDefaultsClient
    ) {
        self.mainQueue = mainQueue
        self.userDefaults = userDefaults
    }

    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var userDefaults: UserDefaultsClient
}

// 308/1.609=191.4232
