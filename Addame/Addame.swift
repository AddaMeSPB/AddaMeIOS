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
import ConversationsView
import EventView
import ProfileView
import SwiftUI
import TabsView

@main
struct AddameApp: App {
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}
