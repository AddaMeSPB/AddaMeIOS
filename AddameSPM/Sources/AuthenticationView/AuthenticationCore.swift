import AuthClient
import AuthClientLive
import Combine
import ComposableArchitecture
import HTTPRequestKit
import KeychainService
import PhoneNumberKit
import SharedModels
import SwiftUI
import UserDefaultsClient

public struct LoginState: Equatable {

  public init() {}

  public static func == (lhs: LoginState, rhs: LoginState) -> Bool {
    return lhs.isAuthorized == rhs.isAuthorized
  }

  public var alert: AlertState<LoginAction>?
  public var authResponse: AuthResponse = .draff
  public var isValidationCodeIsSend = false
  public var isLoginRequestInFlight = false
  public var isAuthorized: Bool = false
  public var isUserFirstNameEmpty: Bool = true
  public var showTermsSheet: Bool = false
  public var showPrivacySheet: Bool = false
}

public enum LoginAction: Equatable {
  case onAppear
  case alertDismissed
  case showTermsSheet
  case showPrivacySheet
  case sendPhoneNumberButtonTapped(String)
  case verificationRequest(String)
  case loninResponse(Result<AuthResponse, HTTPRequest.HRError>)
  case verificationResponse(Result<LoginRes, HTTPRequest.HRError>)
}

public struct AuthenticationEnvironment {
  public var authClient: AuthClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userDefaults: UserDefaultsClient

  public init(
    authClient: AuthClient,
    userDefaults: UserDefaultsClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.authClient = authClient
    self.userDefaults = userDefaults
    self.mainQueue = mainQueue
  }
}

extension AuthenticationEnvironment {
  public static let live: AuthenticationEnvironment = .init(
    authClient: .live(api: .build),
    userDefaults: .live(),
    mainQueue: .main
  )
}

public let loginReducer = Reducer<LoginState, LoginAction, AuthenticationEnvironment> {
  state, action, environment in

  var saveBoolValue: Effect<LoginAction, Never> {
    return environment.userDefaults
      .setBool(true, AppUserDefaults.Key.isAuthorized.rawValue)
      .receive(on: environment.mainQueue)
      .fireAndForget()
  }

  switch action {

  case .onAppear:
    state.isAuthorized = environment.userDefaults
      .boolForKey(AppUserDefaults.Key.isAuthorized.rawValue)
    state.isUserFirstNameEmpty = environment.userDefaults
      .boolForKey(AppUserDefaults.Key.isUserFirstNameEmpty.rawValue)
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none

  case let .sendPhoneNumberButtonTapped(phoneNumber):
    state.isLoginRequestInFlight = true

    do {
      let phoneNumberKit = PhoneNumberKit()
      let parseNumber = try phoneNumberKit.parse(phoneNumber)
      let e164PhoneNumber = phoneNumberKit.format(parseNumber, toType: .e164)
      state.authResponse.phoneNumber = e164PhoneNumber
    } catch {
      print(#line, error.localizedDescription)
      return .none
    }

    return environment.authClient
      .login(state.authResponse)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(LoginAction.loninResponse)

  case let .verificationRequest(code):
    if code.count == 6 {
      state.isLoginRequestInFlight = true
      state.authResponse.code = code

      return environment.authClient
        .verification(state.authResponse)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(LoginAction.verificationResponse)
    }

    return .none

  case let .loninResponse(.success(authResponse)):
    state.isLoginRequestInFlight = false
    state.isValidationCodeIsSend = true
    state.authResponse = authResponse
    return .none

  case let .loninResponse(.failure(error)):
    state.isLoginRequestInFlight = false
    state.isValidationCodeIsSend = false
    state.alert = .init(title: TextState(error.description))

    return .none

  case let .verificationResponse(.success(loginRes)):

    state.isLoginRequestInFlight = false

    KeychainService.save(codable: loginRes.user, for: .user)
    KeychainService.save(codable: loginRes.access, for: .token)

    return .merge(
      environment.userDefaults
        .setBool(true, AppUserDefaults.Key.isAuthorized.rawValue)
        .fireAndForget(),

      environment.userDefaults
        .setBool(loginRes.user.firstName == nil ? false : true, AppUserDefaults.Key.isUserFirstNameEmpty.rawValue)
        .fireAndForget()
    )

  case let .verificationResponse(.failure(error)):
    state.alert = .init(title: TextState("Please try again!") )
      // send this for logs .init(title: TextState(error.description))
    state.isLoginRequestInFlight = false

    return .none

  case .showTermsSheet:
    state.showTermsSheet = true
    return .none

  case .showPrivacySheet:
    state.showPrivacySheet = true
    return .none
  }
}.debug()
