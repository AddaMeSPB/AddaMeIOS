//
//  FiDistanceFilterViewle.swift
//  DistanceFilterView
//
//  Created by Saroar Khandoker on 23.08.2021.
//

import SwiftUI
import ComposableArchitecture
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

public extension DistanceState {
  var view: DistanceFilterView.ViewState {
    DistanceFilterView.ViewState(
      distanceTypeToggleisOn: self.distanceTypeToggleisOn,
      distanceType: self.distanceType,
      distanceValue: self.distanceValue,
      distance: self.distance,
      maxDistance: self.maxDistance
    )
  }
}

extension DistanceState {
  public static let disState = Self(
    distanceValue: 250,
    distance: 250
  )
}

public struct DistanceState: Equatable {
  public init(
    distanceTypeToggleisOn: Bool = true,
    distanceType: DistanceType = .kilometers,
    distanceValue: Double = 0.0,
    distance: Double = 0.0,
    minDistance: Double = 5.0,
    maxDistance: Double = 250.0
  ) {
    self.distanceTypeToggleisOn = distanceTypeToggleisOn
    self.distanceType = distanceType
    self.distanceValue = distanceValue
    self.distance = distance
    self.minDistance = minDistance
    self.maxDistance = maxDistance
  }

  public var distanceTypeToggleisOn: Bool = true
  public var distanceType: DistanceType = .kilometers
  public var distanceValue: Double = 0.0
  public var distance: Double
  public var minDistance: Double = 5.0
  public var maxDistance: Double = 250.0

  public enum DistanceKey: String, Equatable {
    case distance, typee
  }
}

extension DistanceState {
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

public enum DistanceAction: Equatable {
  case onAppear
  case distanceTypeToggleChanged(Bool)
  case distance(_ value: Double)
}

extension DistanceAction {
  static func view(_ localAction: DistanceFilterView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return self.onAppear
    case let .distanceTypeToggleChanged(boolean):
      return self.distanceTypeToggleChanged(boolean)
    case let .distance(value):
      return self.distance(value)
    }
  }
}

extension DistanceFilterView {
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

public struct DistanceFilterView: View {

  let store: Store<DistanceState, DistanceAction>

  public init(store: Store<DistanceState, DistanceAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: DistanceAction.view
      )
    ) { viewStore  in

      VStack(alignment: .leading) {

        Toggle(isOn:
          viewStore.binding(
            get: \.distanceTypeToggleisOn,
            send: ViewAction.distanceTypeToggleChanged
          )
        ) {

          Text("\(viewStore.distanceType.rawValue.capitalized) :")
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(.green)

          Text("\(Int(viewStore.maxDistance))")
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(.green)
        }
        .padding(.vertical)

        Text("Near by distance \(Int(viewStore.distance)) \(viewStore.distanceType.rawValue)")
          .font(.title3)
          .bold()
          .font(.system(.headline, design: .rounded))

        HStack {
          Slider(
            value: viewStore.binding(
              get: \.distance,
              send: ViewAction.distance
            ),
            in: 10...viewStore.maxDistance
          )
          .accentColor(.green)
        }

      }
      .onAppear {
        //
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
    initialState: DistanceState.disState,
    reducer: distanceReducer,
    environment: env
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

public let distanceReducer = Reducer<
  DistanceState, DistanceAction, DistanceEnvironment
> { state, action, environment in
  switch action {

  case .onAppear:
    let distanceTypeIntValue = environment.userDefaults.integerForKey(DistanceState.DistanceKey.typee.rawValue)
    state.distanceTypeToggleisOn = distanceTypeIntValue == 0 ? true : false
    state.distanceType = distanceTypeIntValue == 0 ? .kilometers : .miles
    state.maxDistance = distanceTypeIntValue == 0 ? 250 : (250 * 1.609)

    if environment.userDefaults.doubleForKey(state.distanceType.rawValue) == 0.0 {
      state.distance = state.maxDistance
    } else {
      state.distance = environment.userDefaults.doubleForKey(state.distanceType.rawValue)
    }
    return .none
  case let .distanceTypeToggleChanged(value):

    state.distanceTypeToggleisOn = value
    state.distanceType = value == true ? .kilometers : .miles
    state.maxDistance = value == true ? 250 : (250 * 1.609)

    let distanceIntValue = value == true ? 0 : 1
    state.distance = environment.userDefaults.doubleForKey(state.distanceType.rawValue)

    return environment.userDefaults
      .setInteger(distanceIntValue, DistanceState.DistanceKey.typee.rawValue)
      .fireAndForget()

  case let .distance(value):
    var distanceValue = 0.0
    let distanceTypeIntValue = environment.userDefaults.integerForKey(DistanceState.DistanceKey.typee.rawValue)

    if distanceTypeIntValue == 0 {
      distanceValue = value * 1000
    } else {
      distanceValue = value * 1609
    }

    state.distance = value

    return environment.userDefaults
      .setDouble(distanceValue, state.distanceType.rawValue)
      .fireAndForget()

  }
}

// 308/1.609=191.4232