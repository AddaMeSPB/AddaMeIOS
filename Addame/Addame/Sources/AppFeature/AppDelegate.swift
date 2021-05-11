import UIKit
import ComposableArchitecture
import UserNotifications
import UserNotificationClient
import RemoteNotificationsClient
import AuthClient
import UserClient
import EventClient
import ChatClient
import ConversationClient
import NotificationHelpers
import SettingsView

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
  case didRegisterForRemoteNotifications(Result<Data, NSError>)
  case userNotifications(UserNotificationClient.DelegateEvent)
  case userSettingsLoaded(Result<UserSettings, NSError>)
}

struct AppDelegateEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
  var userNotifications: UserNotificationClient
  var remoteNotifications: RemoteNotificationsClient
  var authClient: AuthClient
  
//  #if DEBUG
//    static let failing = Self(
//      backgroundQueue: .failing("backgroundQueue"),
//      mainQueue: .failing("mainQueue"),
//      remoteNotifications: .failing,
//      setUserInterfaceStyle: { _ in .failing("setUserInterfaceStyle") },
//      userNotifications: .failing
//    )
//  #endif
}

let appDelegateReducer = Reducer<
  UserSettings, AppDelegateAction, AppDelegateEnvironment
> { state, action, environment in
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
    return .none
//    environment.userNotifications.getNotificationSettings
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

  case let .userNotifications(.willPresentNotification(_, completionHandler)):
    return .fireAndForget {
      completionHandler(.banner)
    }

  case .userNotifications:
    return .none

  case let .userSettingsLoaded(result):
    state = (try? result.get()) ?? state
    return environment.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
        // NB: This is necessary because UIKit needs at least one tick of the run loop before we
        //     can set the user interface style.
        .subscribe(on: environment.mainQueue)
        .fireAndForget()
    
  }
}
