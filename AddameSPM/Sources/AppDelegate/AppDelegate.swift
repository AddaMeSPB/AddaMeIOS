//
//  AppDelegate.swift
//  
//
//  Created by Saroar Khandoker on 11.07.2022.
//

import Foundation
import ComposableArchitecture
import UIKit
import DeviceClient
import Combine
import SharedModels
import HTTPRequestKit
import SwiftUI
import UserNotificationClient
import CombineHelpers
import RemoteNotificationsClient
import NotificationHelpers

public struct AppDelegateState: Equatable {
    public init() {}
}

public struct AppDelegateEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var backgroundQueue: AnySchedulerOf<DispatchQueue>
    public var deviceClient: DeviceClient
    public var userNotifications: UserNotificationClient
    public var remoteNotifications: RemoteNotificationsClient

    public init(
      mainQueue: AnySchedulerOf<DispatchQueue>,
      backgroundQueue: AnySchedulerOf<DispatchQueue>,
      devicClient: DeviceClient,
      userNotifications: UserNotificationClient,
      remoteNotifications: RemoteNotificationsClient
    ) {
      self.mainQueue = mainQueue
      self.backgroundQueue = backgroundQueue
      self.deviceClient = devicClient
      self.userNotifications = userNotifications
      self.remoteNotifications = remoteNotifications
    }
}

extension AppDelegateEnvironment {
    public static var live: AppDelegateEnvironment = .init(
        mainQueue: .main,
        backgroundQueue: .main,
        devicClient: .live(api: .build),
        userNotifications: .live,
        remoteNotifications: .live
    )
}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
  case didRegisterForRemoteNotifications(Result<Data, NSError>)
  case deviceResponse(Result<Device, HTTPRequest.HRError>)
  case userNotifications(UserNotificationClient.DelegateEvent)
}

public let appDelegateReducer = Reducer<
  AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { _, action, environment in
  switch action {
  case .didFinishLaunching:
    return .merge(
      // Set notifications delegate
      environment.userNotifications.delegate
        .map(AppDelegateAction.userNotifications),

      environment.userNotifications.getNotificationSettings
        .receive(on: environment.mainQueue)
        .flatMap { settings in
          [.notDetermined, .provisional].contains(settings.authorizationStatus)
            ? environment.userNotifications.requestAuthorization(.provisional)
            : settings.authorizationStatus == .authorized
              ? environment.userNotifications.requestAuthorization([.alert, .sound])
              : .none
        }
        .ignoreFailure()
        .flatMap { successful in
          successful
            ? Effect.registerForRemoteNotifications(
              mainQueue: environment.mainQueue,
              remoteNotifications: environment.remoteNotifications,
              userNotifications: environment.userNotifications
            )
            : .none
        }
        .eraseToEffect()
        .fireAndForget()

    )

  case .didRegisterForRemoteNotifications(.failure):
    return .none

  case let .didRegisterForRemoteNotifications(.success(tokenData)):
    let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
//    return environment.userNotifications.getNotificationSettings
//      .flatMap { settings in
//        environment.apiClient.apiRequest(
//          route: .push(
//            .register(
//              .init(
//                authorizationStatus: .init(rawValue: settings.authorizationStatus.rawValue),
//                build: environment.build.number(),
//                token: token
//              )
//            )
//          )
//        )
//      }
//      .fireAndForget()

      let device = Device(ownerId: "", name: "", model: "", osVersion: "", token: token, voipToken: "")

        return environment.deviceClient.dcu(device, "")
            .subscribe(on: environment.backgroundQueue)
            .catchToEffect()
            .map(AppDelegateAction.deviceResponse)

  case let .userNotifications(.willPresentNotification(_, completionHandler)):
    return .fireAndForget {
      completionHandler(.banner)
    }

  case .userNotifications:
    return .none
  case .deviceResponse(_):
      return .none
  }
}
