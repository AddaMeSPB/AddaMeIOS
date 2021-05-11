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
import RemoteNotificationsClient
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
  case openSettingButtonTapped
  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
  case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
}


public struct SettingsState: Equatable {
  public var alert: AlertState<SettingsAction>?
  public var userNotificationSettings: UserNotificationClient.Notification.Settings?
  public var userSettings: UserSettings
}

public struct SettingsEnvironment {
  public var applicationClient: UIApplicationClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var remoteNotifications: RemoteNotificationsClient
  public var setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
  public var userDefaults: UserDefaultsClient
  public var userNotifications: UserNotificationClient

  public init(
    applicationClient: UIApplicationClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    remoteNotifications: RemoteNotificationsClient,
    setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>,
    userDefaults: UserDefaultsClient,
    userNotifications: UserNotificationClient
  ) {
    self.applicationClient = applicationClient
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.remoteNotifications = remoteNotifications
    self.setUserInterfaceStyle = setUserInterfaceStyle
    self.userDefaults = userDefaults
    self.userNotifications = userNotifications
  }
}
