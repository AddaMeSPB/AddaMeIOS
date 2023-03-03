import ComposableUserNotifications
import Logging
import UIKit
import UserDefaultsClient
import ComposableStoreKit
import UIApplicationClient
import Build
import FoundationExtension
import KeychainClient
import AddaSharedModels
import ComposableArchitecture
import Foundation
import LocationReducer
import os

public struct Settings: ReducerProtocol {
    public struct State: Equatable {
        public init(
            alert: AlertState<Settings.Action>? = nil,
            currentUser: UserOutput = .withFirstName,
            buildNumber: Build.Number? = nil,
            enableNotifications: Bool = false,
            userNotificationSettings: UserNotificationClient.Notification.Settings? = nil,
            userSettings: UserSettings = UserSettings(),
            locationState: LocationReducer.State = .init(),
            distanceState: Distance.State = .init()
        ) {
            self.alert = alert
            self.currentUser = currentUser
            self.buildNumber = buildNumber
            self.enableNotifications = enableNotifications
            self.userNotificationSettings = userNotificationSettings
            self.userSettings = userSettings
            self.locationState = locationState
            self.distanceState = distanceState
        }

        @BindableState public var alert: AlertState<Action>?
        public var currentUser: UserOutput = .withFirstName
        public var buildNumber: Build.Number?

        @BindableState public var enableNotifications: Bool
        public var userNotificationSettings: UserNotificationClient.Notification.Settings?
        public var distanceState: Distance.State
        @BindableState public var userSettings: UserSettings
        @BindableState public var locationState: LocationReducer.State
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case didBecomeActive
        case openSettingButtonTapped
        case userNotificationAuthorizationResponse(TaskResult<Bool>)
        case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
        case leaveUsAReviewButtonTapped
        case reportABugButtonTapped
        case logOutButtonTapped
        case location(LocationReducer.Action)
        case distance(Distance.Action)
    }

    @Dependency(\.applicationClient) var applicationClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.build) var build
    @Dependency(\.keychainClient) var keychainClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        CombineReducers {

            BindingReducer()

            Scope(state: \.distanceState, action: /Action.distance) {
                Distance()
            }

            Reduce { state, action in

                switch action {

                case .binding(_):
                    return .none

                case .binding(\.$enableNotifications):
                    guard
                        state.enableNotifications,
                        let userNotificationSettings = state.userNotificationSettings
                    else {
                        // TODO: API request to opt out of all notifications
                        state.enableNotifications = false
                        return .none
                    }

                    state.userNotificationSettings?.authorizationStatus = state.enableNotifications == true ? .authorized : .denied
                    switch userNotificationSettings.authorizationStatus {
                    case .notDetermined, .provisional:
                        state.enableNotifications = true
                        return .task {
                            await .userNotificationAuthorizationResponse(
                                TaskResult {
                                    try await self.userNotifications.requestAuthorization([.alert, .sound])
                                }
                            )
                        }
                        .animation()

                    case .denied:
                        state.alert = .userNotificationAuthorizationDenied
                        state.enableNotifications = false
                        return .none

                    case .authorized:
                        state.enableNotifications = true
                        return .task { .userNotificationAuthorizationResponse(.success(true)) }

                    case .ephemeral:
                        state.enableNotifications = true
                        return .none

                    @unknown default:
                        return .none
                    }

                case .onAppear:
                    state.buildNumber = self.build.number()

                    do {
                        state.currentUser = try keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
                    } catch {
                        // fatalError("Do soemthing from SettingsFeature!")
                        logger.error("cant get current user from keychainClient ")
                    }

                    return .merge(
                        .run { send in

                            async let settingsResponse: Void = send(
                                .userNotificationSettingsResponse(
                                    self.userNotifications.getNotificationSettings()
                                ),
                                animation: .default
                            )

                            _ = await settingsResponse
                        },

                        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
                            .map { _ in .didBecomeActive }
                            .eraseToEffect()
                    )

                case .openSettingButtonTapped:
                    return .fireAndForget {
                        guard
                            let url = await URL(string: self.applicationClient.openSettingsURLString())
                        else { return }
                        _ = await self.applicationClient.open(url, [:])
                    }

                case let .userNotificationAuthorizationResponse(.success(granted)):
                    state.enableNotifications = granted
                    return granted
                    ?  .none // .fireAndForget { await self.registerForRemoteNotifications() }
                    : .none

                case .userNotificationAuthorizationResponse:
                    return .none

                case let .userNotificationSettingsResponse(settings):
                    state.userNotificationSettings = settings
                    state.enableNotifications = settings.authorizationStatus == .authorized
                    return .none

                case .leaveUsAReviewButtonTapped:

                    return .fireAndForget {
                        _ = await self.applicationClient.open(appStoreReviewUrl, [:])
                    }

                case .didBecomeActive:
                    return .task {
                        await .userNotificationSettingsResponse(
                            self.userNotifications.getNotificationSettings()
                        )
                    }

                case .reportABugButtonTapped:
                    return .fireAndForget { [currentUser = state.currentUser] in
                        let currentUser = currentUser
                        var components = URLComponents()
                        components.scheme = "mailto"
                        components.path = "saroar9@gmail.com"
                        components.queryItems = [
                            URLQueryItem(name: "subject", value: "I found a bug in Addame IOS App"),
                            URLQueryItem(
                                name: "body",
                                value: """


                          ---
                          Build: \(self.build.number()) (\(self.build.gitSha()))
                          \(currentUser.id.hexString)
                          """
                            )
                        ]

                        _ = await self.applicationClient.open(components.url!, [:])
                    }
                case .location(_):
                    return .none
                case .distance(_):
                    return .none
                case .logOutButtonTapped:
                    return .none
                }
            }
        }
    }

    private var appStoreReviewUrl: URL {
      URL(
        string: "https://itunes.apple.com/us/app/apple-store/id1619504857?mt=8&action=write-review"
      )!
    }
}

extension AlertState where Action == Settings.Action {
  static let userNotificationAuthorizationDenied = Self(
    title: .init("Permission Denied"),
    message: .init("Turn on notifications in iOS settings."),
    primaryButton: .default(.init("Ok"), action: .send(.set(\.$alert, nil))),
    secondaryButton: .default(.init("Open Settings"), action: .send(.openSettingButtonTapped))
  )

  static let restoredPurchasesFailed = Self(
    title: .init("Error"),
    message: .init("We couldn’t restore purchases, please try again."),
    dismissButton: .default(.init("Ok"), action: .send(.set(\.$alert, nil)))
  )

  static let noRestoredPurchases = Self(
    title: .init("No Purchases"),
    message: .init("No purchases were found to restore."),
    dismissButton: .default(.init("Ok"), action: .send(.set(\.$alert, nil)))
  )
}

public let logger = Logger(subsystem: "com.addame.AddaMeIOS", category: "settins.reducer")
