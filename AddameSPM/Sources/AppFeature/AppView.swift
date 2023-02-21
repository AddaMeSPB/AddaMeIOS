//
//  AppView.swift
//
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import AuthenticationView
import ComposableArchitecture
import ConversationsView
import EventView
import ProfileView
import SwiftUI
import TabsView
import UserDefaultsClient
import KeychainClient
import AddaSharedModels
import LocationReducer

public struct AppReducer: ReducerProtocol {
    public struct State: Equatable {
        public init(
            loginState: Login.State? = nil,
            tabState: TabReducer.State = .init()
        ) {
            self.loginState = loginState
            self.tabState = tabState
        }

        public var loginState: Login.State?
        public var tabState: TabReducer.State
    }

    public enum Action {
        case onAppear
        case login(Login.Action)
        case tab(TabReducer.Action)
        case appDelegate(AppDelegateReducer.Action)
        case didChangeScenePhase(ScenePhase)
    }

    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.mainRunLoop) var mainRunLoop
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.tabState.profile.settingsState.userSettings, action: /Action.appDelegate) {
            AppDelegateReducer()
        }

        Scope(state: \.tabState, action: /Action.tab) {
            TabReducer()
        }

        Reduce { state, action in

            switch action {
            case .onAppear:
                let isAuthorized = userDefaults.boolForKey(UserDefaultKey.isAuthorized.rawValue) == true
                let isAskPermissionCompleted = userDefaults.boolForKey(UserDefaultKey.isAskPermissionCompleted.rawValue) == true

                if isAuthorized && isAskPermissionCompleted {
                    return .none
                } else {
                    state.loginState = Login.State()
                    return .none
                }

            case .login(.verificationResponse(.success)):

                state.loginState?.registerState = .init()

                return .none
            case .login(.moveToTableView):
                state.loginState = nil
                state.tabState = .init()
                return .none

            case .login:
                return .none

            case .tab(.profile(.settings(.logOutButtonTapped))):

                state.loginState = Login.State()
                return .run(priority: .background) { _ in

                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await userDefaults.setBool(
                                false,
                                UserDefaultKey.isAuthorized.rawValue
                            )
                        }

                        group.addTask {
                            try await keychainClient.logout()
                        }
                    }
                }

            case .tab:
                return .none
            case .appDelegate(_):
                return .none
            case .didChangeScenePhase(_):
                return .none
            }
        }
        .ifLet(\.loginState, action: /Action.login) {
          Login()
        }
    }
}

public struct AppView: View {

    @Environment(\.scenePhase) private var scenePhase

    public let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        public init(state: AppReducer.State) {
            self.isLoginActive = state.loginState != nil
//            self.isOnboardingPresented = state.onBoardingState
        }

        let isLoginActive: Bool
//        let isOnboardingPresented: Bool
  }

    public var body: some View {

        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {

                if !viewStore.isLoginActive {
                    NavigationView {
                        TabsView(
                            store: self.store.scope(
                                state: \.tabState,
                                action: AppReducer.Action.tab
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                } else {
                    IfLetStore(store.scope(
                        state: { $0.loginState },
                        action: AppReducer.Action.login)
                    ) { loginStore in
                        AuthenticationView(store: loginStore)
                    }
                }
            }
        }
        .onAppear {
            ViewStore(store.stateless).send(.onAppear)
        }
        .onChange(of: scenePhase) { phase in
            ViewStore(store.stateless).send(.didChangeScenePhase(phase))
        }

    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: StoreOf<AppReducer>(
            initialState: AppReducer.State(),
            reducer: AppReducer()
        ))
    }
}
#endif
// public struct AppState: Equatable {
//    public var login: LoginState?
//    public var tab: TabState
//
//    public init(
//        loginState: LoginState? = .init(),
//        tabState: TabState = .init(
//            event: .init(),
//            conversations: .init(),
//            profile: .init(),
//            appDelegate: .init(),
//            unreadMessageCount: 0
//        )
//    ) {
//        self.login = loginState
//        self.tab = tabState
//    }
// }
//
// public enum AppAction: Equatable {
//  case onAppear
//  case login(LoginAction)
//  case tab(TabAction)
//  case logout
//  case appDelegate(AppDelegateAction)
//  case didChangeScenePhase(ScenePhase)
//  case accountDeleteResponse(Result<Bool, Never>)
// }
//
// public struct AppEnvironment {
//  public var authenticationClient: AuthClient
//  public var userClient: UserClient
//  public var userDefaults: UserDefaultsClient
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//
//  public init(
//    authenticationClient: AuthClient,
//    userDefaults: UserDefaultsClient,
//    userClient: UserClient,
//    mainQueue: AnySchedulerOf<DispatchQueue>
//  ) {
//    self.authenticationClient = authenticationClient
//    self.userDefaults = userDefaults
//      self.userClient = userClient
//    self.mainQueue = mainQueue
//  }
// }
//
// extension AppEnvironment {
//  public static let live: AppEnvironment = .init(
//    authenticationClient: .live,
//    userDefaults: .live(),
//    userClient: .live,
//    mainQueue: .main
//  )
// }
//
// public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
//  loginReducer
//    .optional()
//    .pullback(
//    state: \.login,
//    action: /AppAction.login,
//    environment: { _ in AuthenticationEnvironment.live }
//  ),
//
//  tabsReducer.pullback(
//    state: \.tab,
//    action: /AppAction.tab,
//    environment: { _ in TabsEnvironment.live }
//  ),
//
//  Reducer { state, action, environment in
//
//    switch action {
//    case .onAppear:
//        // this code move to login and remove onApper
//        state.login = nil
//      if environment.userDefaults.boolForKey(AppUserDefaults.Key.isAuthorized.rawValue) == true {
//          state.tab = .init(
//            event: .init(),
//            conversations: .init(),
//            profile: .init(),
//            appDelegate: .init(),
//            unreadMessageCount: 0
//        )
//          return .none
//      } else {
//          state.login = .init()
//          return .none
//      }
//
//    case let .login(.verificationResponse(.success(loginRes))):
//        state.login = nil
//        state.tab = .init(
//            event: .init(),
//            conversations: .init(),
//            profile: .init(),
//            appDelegate: .init(),
//            unreadMessageCount: 0
//        )
//      return .none
//
//    case .login:
//      return .none
//
//    case let .tab(.profile(.settings(.isLogoutButton(tapped: tapped)))) where tapped:
//      KeychainService.save(codable: UserOutput?.none, for: .user)
//      KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
//      KeychainService.logout()
//      AppUserDefaults.erase()
//
//      state.login = .init()
//      return environment
//        .userDefaults
//        .remove(AppUserDefaults.Key.isAuthorized.rawValue)
//        .fireAndForget()
//
//    case .tab(.profile(.settings(.deleteMeButtonTapped))):
//
//        guard let currentUserID = state.tab.profile.user.id?.hexString else {
//            return .none
//        }
//
//        return .task {
//            do {
//                return AppAction.accountDeleteResponse(
//                    .success(try await environment.userClient.delete(currentUserID))
//                )
//            } catch {
//                // handle error
//                return AppAction.logout
//            }
//        }
////        return .none
//
//    case .tab:
//      return .none
//
//    case .logout:
//      return .none
//
//    case .appDelegate(_):
//        return .none
//    case .didChangeScenePhase(_):
//        return .none
//    case let .accountDeleteResponse(.success(response)):
//
//        guard response == true else { return .none }
//
//        KeychainService.save(codable: UserOutput?.none, for: .user)
//        KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
//        KeychainService.logout()
//        AppUserDefaults.erase()
//
//        state.login = .init()
//
//        return environment
//            .userDefaults
//            .remove(AppUserDefaults.Key.isAuthorized.rawValue)
//            .fireAndForget()
//    }
//  }
// )
//
// public struct AppView: View {
//
//  let store: Store<AppState, AppAction>
//
//  public init(store: Store<AppState, AppAction>) {
//    self.store = store
//  }
//
//  public var body: some View {
//      WithViewStore(store) { _ in
//          IfLetStore(store.scope(
//            state: \.login,
//            action: AppAction.login)
//          ) { loginStore in
//
//              AuthenticationView(store: loginStore)
//          } else: {
//
//              TabsView(store: store.scope(
//                state: \.tab,
//                action: AppAction.tab)
//              )
//
//          }
//      }
//      .onAppear {
//        ViewStore(store.stateless).send(.onAppear)
//      }
//  }
// }
