import AuthClient
import AuthClientLive
import Combine
import ComposableArchitecture
import HttpRequest
import KeychainService
import PhoneNumberKit
import SharedModels
import SwiftUI

public struct LoginState: Equatable {
  public static let build = Self()

  public static func == (lhs: LoginState, rhs: LoginState) -> Bool {
    return lhs.isAuthorized == rhs.isAuthorized
  }

  public var alert: AlertState<LoginAction>?
  public var authResponse: AuthResponse = .draff
  public var isValidationCodeIsSend = false
  public var isLoginRequestInFlight = false
  @AppStorage("isAuthorized") public var isAuthorized: Bool = false
  @AppStorage("isUserFirstNameEmpty") public var isUserFirstNameEmpty: Bool = true
  public var showTermsSheet: Bool = false
  public var showPrivacySheet: Bool = false
}

public enum LoginAction: Equatable {
  case alertDismissed
  case showTermsSheet
  case showPrivacySheet
  case sendPhoneNumberButtonTapped(String)
  case verificationRequest(String)
  case loninResponse(Result<AuthResponse, HTTPError>)
  case verificationResponse(Result<LoginRes, HTTPError>)
}

public struct AuthenticationEnvironment {
  public var authClient = AuthClient.live(api: .build)
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(authClient: AuthClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.authClient = authClient
    self.mainQueue = mainQueue
  }
}

public let loginReducer = Reducer<LoginState, LoginAction, AuthenticationEnvironment> {
  state, action, environment in
  switch action {
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
      print(#line, "")
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
    state.isAuthorized = true
    state.isUserFirstNameEmpty = loginRes.user.firstName == nil ? false : true

    KeychainService.save(codable: loginRes.user, for: .user)
    KeychainService.save(codable: loginRes.access, for: .token)
    return .none

  case let .verificationResponse(.failure(error)):
    state.alert = .init(title: TextState(error.description))
    state.isLoginRequestInFlight = false

    return .none

  case .showTermsSheet:
    state.showTermsSheet = true
    return .none

  case .showPrivacySheet:
    state.showPrivacySheet = true
    return .none
  }
}
