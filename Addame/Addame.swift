//
//  TComposableAAddaMeApp.swift
//  TComposableAAddaMe
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import AppFeature
import ComposableArchitecture
import SwiftUI
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = Store(
    initialState: AppReducer.State()
  ) {
      AppReducer()
          ._printChanges()
  }


  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    self.store.send(.appDelegate(.didFinishLaunching))
    return true
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
      self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
      self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
  }
}

@main
struct AddameApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      AppView(store: self.appDelegate.store)
    }
    .onChange(of: self.scenePhase) {
      self.appDelegate.store.send(.didChangeScenePhase($0))
    }
  }
}

