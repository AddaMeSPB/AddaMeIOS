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
import AddaSharedModels
import AppDelegate
import Network
import UserClient
import UserClientLive

public struct AppState: Equatable {
    public var login: LoginState?
    public var tab: TabState

    public init(
        loginState: LoginState? = .init(),
        tabState: TabState = .init(
            event: .init(),
            conversations: .init(),
            profile: .init(),
            appDelegate: .init(),
            unreadMessageCount: 0
        )
    ) {
        self.login = loginState
        self.tab = tabState
    }
}

public enum AppAction: Equatable {
  case onAppear
  case login(LoginAction)
  case tab(TabAction)
  case logout
  case appDelegate(AppDelegateAction)
  case didChangeScenePhase(ScenePhase)
  case accountDeleteResponse(Result<Bool, Never>)
}

public struct AppEnvironment {
  public var authenticationClient: AuthClient
  public var userClient: UserClient
  public var userDefaults: UserDefaultsClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    authenticationClient: AuthClient,
    userDefaults: UserDefaultsClient,
    userClient: UserClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.authenticationClient = authenticationClient
    self.userDefaults = userDefaults
      self.userClient = userClient
    self.mainQueue = mainQueue
  }
}

extension AppEnvironment {
  public static let live: AppEnvironment = .init(
    authenticationClient: .live,
    userDefaults: .live(),
    userClient: .live,
    mainQueue: .main
  )
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  loginReducer
    .optional()
    .pullback(
    state: \.login,
    action: /AppAction.login,
    environment: { _ in AuthenticationEnvironment.live }
  ),

  tabsReducer.pullback(
    state: \.tab,
    action: /AppAction.tab,
    environment: { _ in TabsEnvironment.live }
  ),

  Reducer { state, action, environment in

    switch action {
    case .onAppear:
        // this code move to login and remove onApper
        state.login = nil
      if environment.userDefaults.boolForKey(AppUserDefaults.Key.isAuthorized.rawValue) == true {
          state.tab = .init(
            event: .init(),
            conversations: .init(),
            profile: .init(),
            appDelegate: .init(),
            unreadMessageCount: 0
        )
          return .none
      } else {
          state.login = .init()
          return .none
      }

    case let .login(.verificationResponse(.success(loginRes))):
        state.login = nil
        state.tab = .init(
            event: .init(),
            conversations: .init(),
            profile: .init(),
            appDelegate: .init(),
            unreadMessageCount: 0
        )
      return .none

    case .login:
      return .none

    case let .tab(.profile(.settings(.isLogoutButton(tapped: tapped)))) where tapped:
      KeychainService.save(codable: UserOutput?.none, for: .user)
      KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
      KeychainService.logout()
      AppUserDefaults.erase()

      state.login = .init()
      return environment
        .userDefaults
        .remove(AppUserDefaults.Key.isAuthorized.rawValue)
        .fireAndForget()

    case .tab(.profile(.settings(.deleteMeButtonTapped))):

        guard let currentUserID = state.tab.profile.user.id?.hexString else {
            return .none
        }

        return .task {
            do {
                return AppAction.accountDeleteResponse(
                    .success(try await environment.userClient.delete(currentUserID))
                )
            } catch {
                // handle error
                return AppAction.logout
            }
        }
//        return .none

    case .tab:
      return .none

    case .logout:
      return .none

    case .appDelegate(_):
        return .none
    case .didChangeScenePhase(_):
        return .none
    case let .accountDeleteResponse(.success(response)):

        guard response == true else { return .none }

        KeychainService.save(codable: UserOutput?.none, for: .user)
        KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
        KeychainService.logout()
        AppUserDefaults.erase()

        state.login = .init()

        return environment
            .userDefaults
            .remove(AppUserDefaults.Key.isAuthorized.rawValue)
            .fireAndForget()
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
          IfLetStore(store.scope(
            state: \.login,
            action: AppAction.login)
          ) { loginStore in

              AuthenticationView(store: loginStore)
          } else: {

              TabsView(store: store.scope(
                state: \.tab,
                action: AppAction.tab)
              )

          }
      }
      .onAppear {
        ViewStore(store.stateless).send(.onAppear)
      }
  }
}
