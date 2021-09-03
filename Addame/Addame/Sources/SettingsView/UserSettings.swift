//
//  UserSettings.swift
//  
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import UIKit
import ComposableArchitecture
import UserNotificationClient
import UIApplicationClient
// import RemoteNotificationsClient
import UserDefaultsClient

public struct UserSettings: Codable, Equatable {
  public var colorScheme: ColorScheme

  public enum ColorScheme: String, CaseIterable, Codable {
    case dark
    case light
    case system

    public var userInterfaceStyle: UIUserInterfaceStyle {
      switch self {
      case .dark:
        return .dark
      case .light:
        return .light
      case .system:
        return .unspecified
      }
    }
  }

  public init(colorScheme: ColorScheme = .system) {
    self.colorScheme = colorScheme
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.colorScheme = (try? container.decode(ColorScheme.self, forKey: .colorScheme)) ?? .system
  }

}

public enum SettingsAction: Equatable {
  case binding(BindingAction<SettingsState>)
  case didBecomeActive
  case leaveUsAReviewButtonTapped
  case onAppear
  case onDismiss
  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
  case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
  case distanceView(DistanceAction)
}

public extension SettingsAction {
  static func view(_ localAction: SettingsView.ViewAction) -> Self {
    switch localAction {
    case .leaveUsAReviewButtonTapped:
      return self.leaveUsAReviewButtonTapped
    case .onAppear:
      return self.onAppear
    case .onDismiss:
      return self.onDismiss
    case let .distanceView(action):
      return self.distanceView(action)    }
  }
}

public extension SettingsState {
  var view: SettingsView.ViewState {
    SettingsView.ViewState(
      alert: self.alert,
      userNotificationSettings: self.userNotificationSettings,
      userSettings: self.userSettings,
      distance: self.distance
    )
  }
}

public struct SettingsState: Equatable {
  public init(
    alert: AlertState<SettingsAction>? = nil,
    userNotificationSettings: UserNotificationClient.Notification.Settings? = nil,
    userSettings: UserSettings = UserSettings(),
    distance: DistanceState = DistanceState()
  ) {
    self.alert = alert
    self.userNotificationSettings = userNotificationSettings
    self.userSettings = userSettings
    self.distance = distance
  }

  public var alert: AlertState<SettingsAction>?
  public var userNotificationSettings: UserNotificationClient.Notification.Settings?
  public var userSettings: UserSettings
  public var distance: DistanceState

}

extension SettingsState {
  public static let settingsSatate = Self(
    userSettings: .init(colorScheme: .dark),
    distance: .disState
  )
}

public struct SettingsEnvironment {
  public var applicationClient: UIApplicationClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  //  public var remoteNotifications: RemoteNotificationsClient
  public var userDefaults: UserDefaultsClient
  public var userNotifications: UserNotificationClient

  public init(
    applicationClient: UIApplicationClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    //    remoteNotifications: RemoteNotificationsClient,
    userDefaults: UserDefaultsClient,
    userNotifications: UserNotificationClient
  ) {
    self.applicationClient = applicationClient
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    //    self.remoteNotifications = remoteNotifications
    self.userDefaults = userDefaults
    self.userNotifications = userNotifications
  }
}

public let settingsReducer = Reducer<
  SettingsState, SettingsAction, SettingsEnvironment
>.combine(
  distanceReducer.pullback(
    state: \.distance,
    action: /SettingsAction.distanceView,
    environment: {
      DistanceEnvironment(
        mainQueue: $0.mainQueue,
        userDefaults: .live()
      )
    }
  ),
  Reducer { _, action, _ in
    switch action {
    case let .binding(settingsState):
      return .none
    case .didBecomeActive:
      return .none
    case .leaveUsAReviewButtonTapped:
      return .none
    case .onAppear:
      return .none
    case .onDismiss:
      return .none
    case let .userNotificationAuthorizationResponse(value):
      return .none
    case let .userNotificationSettingsResponse(value):
      return .none
    case let .distanceView(action):
      return .none
    }
  }
)
