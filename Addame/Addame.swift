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
import AppDelegate
import UIKit

public final class AppDelegate: NSObject, UIApplicationDelegate {
  public let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: .live
  )

  public lazy var viewStore = ViewStore(
    self.store.scope(state: { _ in () }),
    removeDuplicates: ==
  )

  public  func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      self.viewStore.send(.appDelegate(.didFinishLaunching))
      return true
    }

   public func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
    }

   public func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      self.viewStore.send(
        .appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError)))
      )
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
      self.appDelegate.viewStore.send(.didChangeScenePhase($0))
    }
  }
}
