import Combine
import Foundation
import HTTPRequestKit
import SharedModels

public struct AuthClient {
  public typealias LoginHandler = (AuthResponse) -> AnyPublisher<AuthResponse, HTTPRequest.HRError>
  public typealias VerificationHandler = (AuthResponse) -> AnyPublisher<LoginRes, HTTPRequest.HRError>

  public var login: LoginHandler
  public var verification: VerificationHandler

  public init(
    login: @escaping LoginHandler,
    verification: @escaping VerificationHandler
  ) {
    self.login = login
    self.verification = verification
  }
}
