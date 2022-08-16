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
import AddaSharedModels
import HTTPRequestKit
import SwiftUI
import UserNotificationClient
import CombineHelpers
import RemoteNotificationsClient
import NotificationHelpers
import FoundationExtension
import KeychainService

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
        devicClient: .live,
        userNotifications: .live,
        remoteNotifications: .live
    )
}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
  case didRegisterForRemoteNotifications(Result<Data, NSError>)
  case deviceResponse(Result<DeviceInOutPut, HTTPRequest.HRError>)
  case userNotifications(UserNotificationClient.DelegateEvent)
  case sendDeviceInfo
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
            [.denied, .notDetermined, .authorized].contains(settings.authorizationStatus)
            ? environment.userNotifications.requestAuthorization([.alert, .badge, .sound])
            : settings.authorizationStatus == .authorized
            ? environment.userNotifications.requestAuthorization([.alert, .badge, .sound])
            : .none
        }
        .ignoreFailure()
        .print()
        .flatMap { successful in

          successful
            ? Effect.registerForRemoteNotifications(
              mainQueue: environment.mainQueue,
              remoteNotifications: environment.remoteNotifications,
              userNotifications: environment.userNotifications
            )
            : Effect.unregisterForRemoteNotifications(
                mainQueue: environment.mainQueue,
                remoteNotifications: environment.remoteNotifications,
                userNotifications: environment.userNotifications
            )
        }
        .eraseToEffect()
        .fireAndForget()

      // need get action when user dont give permision

    )

  case let .didRegisterForRemoteNotifications(.failure(error)):
      print("didRegisterForRemoteNotifications faifure", error.debugDescription)
    return .none

  case let .didRegisterForRemoteNotifications(.success(tokenData)):
      let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString
      let token = tokenData.toHexString
      let device = DeviceInOutPut(
        identifierForVendor: identifierForVendor,
        name: UIDevice.current.name,
        model: UIDevice.current.model,
        osVersion: UIDevice.current.systemVersion,
        token: token,
        voipToken: ""
      )

      KeychainService.save(string: token, for: .deviceToken)
      return .task {
          do {
              let deviceResponse = try await environment.deviceClient.dcu(device)
              return AppDelegateAction.deviceResponse(.success(deviceResponse))
          } catch {
              return AppDelegateAction.deviceResponse(.failure(.custom("cant save device", error)))
          }
      }

  case let .userNotifications(.willPresentNotification(_, completionHandler)):
    return .fireAndForget { completionHandler(.banner) }

  case .userNotifications:
    return .none

  case .sendDeviceInfo:

      let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString

      let device = DeviceInOutPut(
        identifierForVendor: identifierForVendor,
        name: UIDevice.current.name,
        model: UIDevice.current.model,
        osVersion: UIDevice.current.systemVersion,
        token: "",
        voipToken: ""
      )

      return .task {
          do {
              let deviceResponse = try await environment.deviceClient.dcu(device)
              return AppDelegateAction.deviceResponse(.success(deviceResponse))
          } catch {
              return AppDelegateAction.deviceResponse(.failure(.custom("cant save device", error)))
          }
      }

  case let .deviceResponse(.success(deviceResponse)):
      print("deviceResponse", deviceResponse)
      return .none

  case let .deviceResponse(.failure(error)):
      print("deviceRespones error: \(error.description)", error)
      return .none
  }
}
