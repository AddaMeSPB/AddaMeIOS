//
//  TComposableAAddaMeApp.swift
//  TComposableAAddaMe
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import ComposableArchitecture
import SwiftUI
import EventView
import ChatView
import ProfileView
import Tabs
import AuthenticationCore
import AuthClient
import AuthClientLive

@main
struct AddameApp: App {
  
  @AppStorage("isAuthorized")
  public var isAuthorized: Bool = false
  
  static let tabsState = TabsState(
    selectedTab: .event,
    event: EventsState(),
    chat: ChatState(),
    profile: ProfileState()
  )

  let tabsStore = Store(
    initialState: tabsState,
    reducer: tabsReducer.debug(),
    environment: ()
  )

  static let environment = AuthenticationEnvironment(
    authClient: AuthClient.live(api: .build) ,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
  )

  static let authState = LoginState.build
  let authStore = Store(initialState: authState, reducer: loginReducer, environment: environment)

  var body: some Scene {
    WindowGroup {
      if isAuthorized {
        TabsView(store: tabsStore)
      } else {
        AuthenticationView(store: authStore)
      }
    }
  }
}
