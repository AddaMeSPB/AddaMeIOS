import Combine
import Foundation
import HTTPRequestKit
import AddaSharedModels
import SwiftUI
import InfoPlist
import KeychainService
import URLRouting

public struct ConversationClient {

    public static let apiClient: URLRoutingClient<SiteRoute> = .live(
      router: siteRouter.baseRequestData(
          .init(
              scheme: EnvironmentKeys.rootURL.scheme,
              host: EnvironmentKeys.rootURL.host,
              port: EnvironmentKeys.setPort(),
              headers: [
                  "Authorization": ["Bearer \(accessTokenTemp)"]
              ]
          )
      )
    )

  public typealias ConversationCreateHandler = @Sendable (ConversationCreate) async throws -> ConversationOutPut
  public typealias AddUserToConversationHandler = @Sendable (AddUser) async throws -> AddUser
  public typealias ConversationListHandler = @Sendable (QueryItem) async throws -> ConversationsResponse
  public typealias ConversationFindHandler = @Sendable (String) async throws -> ConversationOutPut

  public let create: ConversationCreateHandler
  public let addUserToConversation: AddUserToConversationHandler
  public let list: ConversationListHandler
  public let find: ConversationFindHandler

  public init(
    create: @escaping ConversationCreateHandler,
    addUserToConversation: @escaping AddUserToConversationHandler,
    list: @escaping ConversationListHandler,
    find: @escaping ConversationFindHandler
  ) {
    self.create = create
    self.addUserToConversation = addUserToConversation
    self.list = list
    self.find = find
  }
}
