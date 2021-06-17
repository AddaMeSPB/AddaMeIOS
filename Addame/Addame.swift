//
//  TComposableAAddaMeApp.swift
//  TComposableAAddaMe
//
//  Created by Saroar Khandoker on 05.04.2021.
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
import AppFeature

@main
struct AddameApp: App {

  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}
