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

public enum AppState: Equatable {
  case login(LoginState)
  case tabs(TabsViewState)

  public init() { self = .login(.init()) }
}

public enum AppAction: Equatable {
  case onAppear
  case login(LoginAction)
  case tabs(TabsAction)
  case logout
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
  loginReducer.pullback(
    state: /AppState.login,
    action: /AppAction.login,
    environment: { _ in AuthenticationEnvironment.live }
  ),
  tabsReducer.pullback(
    state: /AppState.tabs,
    action: /AppAction.tabs,
    environment: { _ in TabsEnvironment.live }
  ),
  Reducer { state, action, environment in
    switch action {
    case .onAppear:

      if environment.userDefaults.boolForKey(AppUserDefaults.Key.isAuthorized.rawValue) == true {
        state = .tabs(
          .init(
            selectedTab: .event,
            event: EventsState(),
            conversations: ConversationsState(),
            profile: ProfileState()
          )
        )
      }
      return .none

    case let .login(.verificationResponse(.success(loginRes))):
//      where environment.userDefaults.boolForKey(AppUserDefaults.Key.isAuthorized.rawValue):

      state = .tabs(
        .init(
          selectedTab: .event,
          event: EventsState(),
          conversations: ConversationsState(),
          profile: ProfileState()
        )
      )
      return .none

    case .login:
      return .none

    case let .tabs(.profile(.settings(.isLogoutButton(tapped: tapped)))) where tapped:
      KeychainService.save(codable: User?.none, for: .user)
      KeychainService.save(codable: AuthResponse?.none, for: .token)
      KeychainService.logout()
      AppUserDefaults.erase()

      state = .login(.init())
      return environment
        .userDefaults
        .remove(AppUserDefaults.Key.isAuthorized.rawValue)
        .fireAndForget()

    case .tabs:
      return .none

    case .logout:
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
    SwitchStore(self.store) {
      CaseLet(state: /AppState.login, action: AppAction.login) { store in
        AuthenticationView(store: store)
      }
      CaseLet(state: /AppState.tabs, action: AppAction.tabs) { store in
          TabsView(store: store)
      }
    }
    .onAppear {
      ViewStore(store.stateless).send(.onAppear)
    }
  }
}
