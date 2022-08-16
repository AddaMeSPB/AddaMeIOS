import Combine
import Foundation
import AddaSharedModels
import URLRouting
import InfoPlist

public struct AuthClient {

    static public let apiClient: URLRoutingClient<SiteRoute> = .live(
        router: siteRouter.baseRequestData(
            .init(
                scheme: EnvironmentKeys.rootURL.scheme,
                host: EnvironmentKeys.rootURL.host,
                port: EnvironmentKeys.setPort()
            )
        )
    )

  public typealias LoginHandler = @Sendable (VerifySMSInOutput) async throws -> VerifySMSInOutput
  public typealias VerificationHandler = @Sendable (VerifySMSInOutput) async throws -> LoginResponse

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
