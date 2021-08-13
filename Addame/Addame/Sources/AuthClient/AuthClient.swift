import Combine
import Foundation
import HttpRequest
import SharedModels

public struct AuthClient {

  public typealias LoginHandler = (AuthResponse) -> AnyPublisher<AuthResponse, HTTPError>
  public typealias VerificationHandler = (AuthResponse) -> AnyPublisher<LoginRes, HTTPError>

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
