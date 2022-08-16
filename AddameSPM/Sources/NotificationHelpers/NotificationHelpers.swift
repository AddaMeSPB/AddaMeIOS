//
//  NotificationHelpers.swift
//
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import Combine
import ComposableArchitecture
import RemoteNotificationsClient
import UserNotificationClient
import Foundation

extension Effect where Output == Never, Failure == Never {
  public static func registerForRemoteNotifications(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    remoteNotifications: RemoteNotificationsClient,
    userNotifications: UserNotificationClient
  ) -> Self {
    userNotifications.getNotificationSettings
      .receive(on: mainQueue)
      .flatMap { settings in
        settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
          ? remoteNotifications.register()
          : .none
      }
      .eraseToEffect()
  }

    public static func unregisterForRemoteNotifications(
      mainQueue: AnySchedulerOf<DispatchQueue>,
      remoteNotifications: RemoteNotificationsClient,
      userNotifications: UserNotificationClient
    ) -> Self {
      userNotifications.getNotificationSettings
        .receive(on: mainQueue)
        .flatMap { settings in
            settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied
            ? remoteNotifications.unregister()
            : .none
        }
        .eraseToEffect()
    }
}
