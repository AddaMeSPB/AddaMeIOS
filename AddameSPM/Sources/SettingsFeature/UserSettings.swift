import SwiftUI

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

// import ComposableArchitecture
// import UIApplicationClient
// import UIKit
//// import RemoteNotificationsClient
// import UserDefaultsClient
// import ComposableUserNotifications
// import AddaSharedModels
// import AuthenticationView
//
// public struct UserSettings: Codable, Equatable {
//  public var colorScheme: ColorScheme
//
//  public enum ColorScheme: String, CaseIterable, Codable {
//    case dark
//    case light
//    case system
//
//    public var userInterfaceStyle: UIUserInterfaceStyle {
//      switch self {
//      case .dark:
//        return .dark
//      case .light:
//        return .light
//      case .system:
//        return .unspecified
//      }
//    }
//  }
//
//  public init(colorScheme: ColorScheme = .system) {
//    self.colorScheme = colorScheme
//  }
//
//  public init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    colorScheme = (try? container.decode(ColorScheme.self, forKey: .colorScheme)) ?? .system
//  }
// }
//
// public enum SettingsAction: Equatable {
//  case binding(BindingAction<SettingsState>)
//  case didBecomeActive
//  case leaveUsAReviewButtonTapped
//  case onAppear
//  case onDismiss
//  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
//  case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
//  case distanceView(DistanceAction)
//  case resetAuthData
//  case deleteMeButtonTapped
//  case isLogoutButton(tapped: Bool)
//  case termsSheet(isPresented: Bool, url: String?)
//  case privacySheet(isPresented: Bool, url: String?)
//  case termsAndPrivacy(TermsAndPrivacyAction)
// }
//
// extension SettingsAction {
//  public static func view(_ localAction: SettingsView.ViewAction) -> Self {
//    switch localAction {
//    case .leaveUsAReviewButtonTapped:
//      return leaveUsAReviewButtonTapped
//    case .onAppear:
//      return onAppear
//    case .onDismiss:
//      return onDismiss
//    case let .distanceView(action):
//      return distanceView(action)
//    case .resetAuthData:
//      return resetAuthData
//    case .deleteMeButtonTapped:
//        return deleteMeButtonTapped
//    case let .isLogoutButton(tapped: tapped):
//      return .isLogoutButton(tapped: tapped)
//    case let .termsSheet(isPresented: isPresented, url: url):
//      return termsSheet(isPresented: isPresented, url: url)
//    case let .privacySheet(isPresented: isPresented, url: url):
//      return privacySheet(isPresented: isPresented, url: url)
//    }
//  }
// }
//
// extension SettingsState {
//  public var view: SettingsView.ViewState {
//    SettingsView.ViewState(
//      alert: alert,
//      userNotificationSettings: userNotificationSettings,
//      userSettings: userSettings,
//      distance: distance
//    )
//  }
// }
//
// public struct SettingsState: Equatable {
//  public init(
//    alert: AlertState<SettingsAction>? = nil,
//    userNotificationSettings: UserNotificationClient.Notification.Settings? = nil,
//    userSettings: UserSettings = UserSettings(),
//    distance: DistanceState = DistanceState(),
//    termsAndPrivacyState: TermsAndPrivacyState? = nil
//  ) {
//    self.alert = alert
//    self.userNotificationSettings = userNotificationSettings
//    self.userSettings = userSettings
//    self.distance = distance
//    self.termsAndPrivacyState = termsAndPrivacyState
//  }
//
//  public var alert: AlertState<SettingsAction>?
//  public var userNotificationSettings: UserNotificationClient.Notification.Settings?
//  public var userSettings: UserSettings
//  public var distance: DistanceState
//  public var termsAndPrivacyState: TermsAndPrivacyState?
// }
//
// extension SettingsState {
//  public static let settingsSatate = Self(
//    userSettings: .init(colorScheme: .dark),
//    distance: .disState
//  )
// }
//
// public struct SettingsEnvironment {
//  public var applicationClient: UIApplicationClient
//  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
//  public var mainQueue: AnySchedulerOf<DispatchQueue>
//  //  public var remoteNotifications: RemoteNotificationsClient
//  public var userDefaults: UserDefaultsClient
//  public var userNotifications: UserNotificationClient
//
//  public init(
//    applicationClient: UIApplicationClient,
//    backgroundQueue: AnySchedulerOf<DispatchQueue>,
//    mainQueue: AnySchedulerOf<DispatchQueue>,
//    //    remoteNotifications: RemoteNotificationsClient,
//    userDefaults: UserDefaultsClient,
//    userNotifications: UserNotificationClient
//  ) {
//    self.applicationClient = applicationClient
//    self.backgroundQueue = backgroundQueue
//    self.mainQueue = mainQueue
//    //    self.remoteNotifications = remoteNotifications
//    self.userDefaults = userDefaults
//    self.userNotifications = userNotifications
//  }
// }
//
// extension SettingsEnvironment {
//  public static let live: SettingsEnvironment = .init(
//    applicationClient: .noop,
//    backgroundQueue: .main,
//    mainQueue: .main,
//    userDefaults: .live(),
//    userNotifications: .live
//  )
// }
//
// public let settingsReducer = Reducer<
//  SettingsState, SettingsAction, SettingsEnvironment
// >.combine(
//  distanceReducer.pullback(
//    state: \.distance,
//    action: /SettingsAction.distanceView,
//    environment: { _ in DistanceEnvironment.live }
//  ),
//  Reducer { state, action, _ in
//    switch action {
//    case let .binding(settingsState):
//      return .none
//    case .didBecomeActive:
//      return .none
//    case .leaveUsAReviewButtonTapped:
//      return .none
//    case .onAppear:
//      return .none
//    case .onDismiss:
//      return .none
//    case let .userNotificationAuthorizationResponse(value):
//      return .none
//    case let .userNotificationSettingsResponse(value):
//      return .none
//    case let .distanceView(action):
//      return .none
//    case .resetAuthData:
//      return .none
//    case .deleteMeButtonTapped:
//      return .none
//    case let .isLogoutButton(tapped: tapped):
//      return .none
//    // swiftlint:disable pattern_matching_keywords
//    case .termsSheet(isPresented: let isPresented, url: let url):
//      state.termsAndPrivacyState = isPresented ? TermsAndPrivacyState(urlString: url) : nil
//      return .none
//
//    // swiftlint:disable pattern_matching_keywords
//    case .privacySheet(isPresented: let isPresented, url: let url):
//      return .none
//    case .termsAndPrivacy(_):
//      return .none
//    }
//  }
// )
// .presenting(
//  termsAndPrivacyReducer,
//  state: .keyPath(\.termsAndPrivacyState),
//  id: .notNil(),
//  action: /SettingsAction.termsAndPrivacy,
//  environment: { _ in TermsAndPrivacyEnvironment.live }
// )
