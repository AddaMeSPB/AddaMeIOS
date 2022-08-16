import Combine
import Foundation
import FoundationExtension
import AddaSharedModels
import URLRouting
import InfoPlist
import KeychainService

public struct ChatClient {
    // swiftlint:disable superfluous_disable_command
    public static let apiClient: URLRoutingClient<SiteRoute> = .live(

      router: siteRouter.baseRequestData(
          .init(
              scheme: EnvironmentKeys.rootURL.scheme,
              host: EnvironmentKeys.rootURL.host,
              port: EnvironmentKeys.setPort(),
              headers: [
                  "Authorization": [
                      "Bearer \(accessTokenTemp)"
                  ]
              ]
          )
      )
    )

  public typealias MessageListHandler = @Sendable (QueryItem, String) async throws -> MessagePage

  public let messages: MessageListHandler

  public init(
    messages: @escaping MessageListHandler
  ) {
    self.messages = messages
  }
}
