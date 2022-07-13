//
//  AppView.swift
//
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import AuthClient
import AuthClientLive
import AuthenticationView
import ComposableArchitecture
import ConversationsView
import EventView
import ProfileView
import SwiftUI
import TabsView
import UserDefaultsClient
import KeychainService
import SharedModels
import AppDelegate
import Network

public struct AppState: Equatable {
    public init(
        loginState: LoginState? = .init(),
        tabsState: TabsViewState = .init()
    ) {
        self.loginState = loginState
        self.tabsState = tabsState
    }

    public var loginState: LoginState?
    public var tabsState: TabsViewState
}

public enum AppAction: Equatable {
  case onAppear
  case login(LoginAction)
  case tabs(TabsAction)
  case logout
  case appDelegate(AppDelegateAction)
  case didChangeScenePhase(ScenePhase)
}

public struct AppEnvironment {
  public var authenticationClient: AuthClient
  public var userDefaults: UserDefaultsClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    authenticationClient: AuthClient,
    userDefaults: UserDefaultsClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.authenticationClient = authenticationClient
    self.userDefaults = userDefaults
    self.mainQueue = mainQueue
  }
}

extension AppEnvironment {
  public static let live: AppEnvironment = .init(
    authenticationClient: .live(api: .build),
    userDefaults: .live(),
    mainQueue: .main
  )
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  loginReducer
    .optional()
    .pullback(
    state: \.loginState,
    action: /AppAction.login,
    environment: { _ in AuthenticationEnvironment.live }
  ),

  tabsReducer.pullback(
    state: \.tabsState,
    action: /AppAction.tabs,
    environment: { _ in TabsEnvironment.live }
  ),

  appDelegateReducer.pullback(
    state: \.tabsState.appDelegate,
    action: /AppAction.appDelegate,
    environment: { _ in AppDelegateEnvironment.live }
  ),

  Reducer { state, action, environment in

    switch action {
    case .onAppear:
        // this code move to login and remove onApper
        state.loginState = nil
      if environment.userDefaults.boolForKey(AppUserDefaults.Key.isAuthorized.rawValue) == true {
          state.tabsState = .init()
      } else {
          state.loginState = .init()
      }
      return .none

    case let .login(.verificationResponse(.success(loginRes))):
        state.loginState = nil
        state.tabsState = .init()
      return .none

    case .login:
      return .none

    case let .tabs(.profile(.settings(.isLogoutButton(tapped: tapped)))) where tapped:
      KeychainService.save(codable: User?.none, for: .user)
      KeychainService.save(codable: AuthResponse?.none, for: .token)
      KeychainService.logout()
      AppUserDefaults.erase()

      state.loginState = .init()
      return environment
        .userDefaults
        .remove(AppUserDefaults.Key.isAuthorized.rawValue)
        .fireAndForget()

    case .tabs:
      return .none

    case .logout:
      return .none

    case .appDelegate(_):
        return .none
    case .didChangeScenePhase(_):
        return .none
    }
  }
)

public struct AppView: View {

  let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  public var body: some View {
      WithViewStore(store) { _ in
          IfLetStore(store.scope(state: { $0.loginState },
                                 action: AppAction.login)) { loginStore in

              AuthenticationView(store: loginStore)
          } else: {

              TabsView(store: store.scope(state: { $0.tabsState },
                                    action: AppAction.tabs) )

          }
      }
      .onAppear {
        ViewStore(store.stateless).send(.onAppear)
      }

  }
}
