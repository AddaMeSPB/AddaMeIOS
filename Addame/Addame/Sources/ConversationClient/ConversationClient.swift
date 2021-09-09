import Combine
import Foundation
import HttpRequest
import SharedModels
import SwiftUI

public struct ConversationClient {
  public typealias ConversationCreateHandler =
    (CreateConversation, String) -> AnyPublisher<ConversationResponse.Item, HTTPError>
  public typealias AddUserToConversationHandler = (AddUser, String)
    -> AnyPublisher<ConversationResponse.UserAdd, HTTPError>
  public typealias ConversationListHandler = (QueryItem, String) -> AnyPublisher<
    ConversationResponse, HTTPError
  >
  public typealias ConversationFindHandler = (String, String) -> AnyPublisher<
    ConversationResponse.Item, HTTPError
  >

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
