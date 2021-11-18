//
//  TComposableAAddaMeApp.swift
//  TComposableAAddaMe
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import AppFeature
import AuthClient
import AuthClientLive
import AuthenticationView
import ComposableArchitecture
import SwiftUI
import TabsView

@main
struct AddameApp: App {
  let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: .live
  )

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
