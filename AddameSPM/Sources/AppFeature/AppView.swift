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
import NotificationHelpers

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
    @Dependency(\.remoteNotifications) var remoteNotifications
    @Dependency(\.mainRunLoop) var mainRunLoop
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.tabState.settings.userSettings, action: /Action.appDelegate) {
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

            case .tab(.settings(.logOutButtonTapped)):
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

            case let .appDelegate(.userNotifications(.didReceiveResponse(_, completionHandler))):

              return .fireAndForget { completionHandler() }

            case .appDelegate:
                return .none

            case .didChangeScenePhase(.active):
                return .run { send in
                    await send(.tab(.connect))
                }

            case .didChangeScenePhase(.background):
                return .run { send in
                    await send(.tab(.disConnect))
                }

            case .didChangeScenePhase:
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
