//
//  AppView.swift
//  
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import ComposableArchitecture
import SwiftUI
import EventView
import ConversationsView
import ProfileView
import TabsView
import AuthenticationView
import AuthClient
import AuthClientLive

public struct AppView: View {
  
  public init() {}
  
  @AppStorage("isAuthorized")
  public var isAuthorized: Bool = false
  
  static let tabsEnv = TabsEnvironment(
    backgroundQueue: .main,
    mainQueue: .main
  )
  
  static let tabsState = TabsState(
    selectedTab: .event,
    event: EventsState(),
    conversations: ConversationsState(),
    profile: ProfileState()
  )

  let tabsStore = Store(
    initialState: tabsState,
    reducer: tabsReducer.debug(),
    environment: tabsEnv
  )

  static let environment = AuthenticationEnvironment(
    authClient: AuthClient.live(api: .build) ,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
  )

  static let authState = LoginState.build
  let authStore = Store(initialState: authState, reducer: loginReducer, environment: environment)

  public var body: some View {
    Group {
      if isAuthorized {
        TabsView(store: tabsStore)
      } else {
        AuthenticationView(store: authStore)
      }
    }
  }
}
