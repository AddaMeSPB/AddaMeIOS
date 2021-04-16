import ComposableArchitecture
import Common
import Combine
import FuncNetworking
import SwiftUI
import PhoneNumberKit
import AddaMeModels
import AuthClient
import AuthClientLive

struct AuthenticationCore {}

public struct LoginState: Equatable {
  
  public static let build = Self ()
  
  public static func == (lhs: LoginState, rhs: LoginState) -> Bool {
    return lhs.isAuthorized == rhs.isAuthorized
  }
  
  public var alert: AlertState<LoginAction>?
  public var authResponse: AuthResponse = .draff
  public var isValidationCodeIsSend = false
  public var isLoginRequestInFlight = false
  @AppStorage("isAuthorized") public var isAuthorized: Bool = false
  @AppStorage("isUserFirstNameEmpty") public var isUserFirstNameEmpty: Bool = true
  public var isValidPhoneNumber: Bool = false
  public var showTermsSheet: Bool = false
  public var showPrivacySheet: Bool = false
}

public enum LoginAction: Equatable {
  case alertDismissed
  case showTermsSheet
  case showPrivacySheet
  case sendPhoneNumberButtonTapped
  case loginRequest(String)
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

public let loginReducer = Reducer<LoginState, LoginAction, AuthenticationEnvironment> { state, action, environment in
  switch action {
  
  case .alertDismissed:
    state.alert = nil
    return .none
  case .sendPhoneNumberButtonTapped:
    state.isLoginRequestInFlight = true
    
    return environment.authClient
      .login(state.authResponse)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(LoginAction.loninResponse)
    
  case let .loginRequest(phoneNumber):
    state.authResponse.phoneNumber = phoneNumber
    
    return .none
    
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
      
  case .loninResponse(.success(let authResponse)):
    state.isLoginRequestInFlight = false
    state.isValidationCodeIsSend = true
    state.authResponse = authResponse
    return .none
    
  case .loninResponse(.failure(let error)):
    state.isLoginRequestInFlight = false
    state.isValidationCodeIsSend = false
    state.alert = .init(title: TextState(error.localizedDescription))
    
    return .none
    
  case .verificationResponse(.success(let loginRes)):
    state.isLoginRequestInFlight = false
    state.isAuthorized = true
    state.isUserFirstNameEmpty = loginRes.user.firstName == nil ? false : true
//    saveCurrentUserAndToken(loginRes)
    return .none
  
  case .verificationResponse(.failure(let error)):
    state.alert = .init(title: TextState(error.localizedDescription))
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

//private func saveCurrentUserAndToken(_ res: LoginRes) {
//  KeychainService.save(codable: res.user, for: .user)
//  KeychainService.save(codable: res.access, for: .token)
//}
