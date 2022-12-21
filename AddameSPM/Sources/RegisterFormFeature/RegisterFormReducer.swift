import SwiftUI
import ComposableArchitecture
import ComposableUserNotifications
import UserDefaultsClient
import AddaSharedModels
import UserNotifications
import URLRouting
import KeychainClient
import Combine
import Dependencies
import FoundationExtension
import APIClient
import IDFAClient
import AdSupport
import AppTrackingTransparency
import CoreLocation
import LocationReducer

public struct RegisterFormReducer: ReducerProtocol {
    public struct State: Equatable {

      @BindableState public var selectedPage = FormTag.notificationPermission

      public var alert: AlertState<Action>?

      @BindableState public var isNotificationContinueButtonValid: Bool = false
      @BindableState public var isLocationEnableContinueButtonValid: Bool = false
      @BindableState public var isIDFAEbableContinueButtonValid: Bool = false
      public var locationState: LocationReducer.State?

      public var waitingForLoginView: Bool = false

      public init(locationState: LocationReducer.State? = nil) {
          self.locationState = locationState
      }

    }

    public enum Action: BindableAction, Equatable {
      case binding(BindingAction<RegisterFormReducer.State>)
      case selectedPage(FormTag)
      case onApper
      case selectedPageButtonTapped
      case moveToLoginView
      case alertDismissed

      case isNotificationContinueButtonTapped
      case isLocationEnableContinueButtonTapped
      case isIDFAEbableContinueButtonTapped

      case requestLocationAuthorizationResponse(CLAuthorizationStatus)
      case userNotificationAuthorizationResponse(Bool)
      case idfaAuthorizationStatus(ATTrackingManager.AuthorizationStatus)
      case location(LocationReducer.Action)
        
    }

    public init() {}

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.mainRunLoop) var mainRunLoop
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.idfaClient) var idfaClient
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.locationManager) var locationManager

    enum NameFormCanceable {}

    public var body: some ReducerProtocol<State, Action> {

        BindingReducer()
        Reduce { state, action in
            switch action {

            case .selectedPage:
                return .none

            case .onApper:
                return .none

            case .binding:
                return .none

            case .selectedPageButtonTapped:
                return .none

            case .moveToLoginView:
                return .none

            case .alertDismissed:
                state.alert = nil
                return .none

            case .isNotificationContinueButtonTapped:
                return .run { send in
                    let boolValue = try await self.userNotifications.requestAuthorization([.alert, .sound])
                    await send(.userNotificationAuthorizationResponse(boolValue))
                }
                
            case .isLocationEnableContinueButtonTapped:
                return .run { send in
                    await send(.location(.askLocationPermission))
                }

            case .isIDFAEbableContinueButtonTapped:
                state.waitingForLoginView = true

                return .run { send in
                    await send(.location(.tearDown))
                    let status = await idfaClient.requestAuthorization()
                    await send(.idfaAuthorizationStatus(status))
                }

            case .userNotificationAuthorizationResponse:
                state.locationState = .init()
                state.selectedPage = .locationPermission
                return .run { send in
                    await send(.location(.delegate))
                }

            case .requestLocationAuthorizationResponse:
                state.selectedPage = .IDFAPermission
                return .none

            case .idfaAuthorizationStatus:
                state.locationState = nil
                
                return .run { send in

                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await self.userDefaults.setBool(
                                true,
                                UserDefaultKey.isAskPermissionCompleted.rawValue
                            )
                        }

                        group.addTask {
                            try await self.mainQueue.sleep(for: .seconds(1))
                            await send(.moveToLoginView)
                        }
                        
                    }
                }

            case .location(.getLocation):
                return .none

            case let .location(.locationManager(.didChangeAuthorization(status))):

                if self.locationManager.authorizationStatus() == .notDetermined {
                    return .none
                }

                return .run { send in
                    await send(.requestLocationAuthorizationResponse(status))
                }

            case .location:
                return .none
            }
        }
        .ifLet(\.locationState, action: /Action.location) {
           LocationReducer()
        }
    }

}

public enum FormTag: Equatable {
  case notificationPermission, locationPermission, IDFAPermission
}
