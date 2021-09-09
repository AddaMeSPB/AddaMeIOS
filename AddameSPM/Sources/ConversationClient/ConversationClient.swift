import Combine
import Foundation
import HTTPRequestKit
import SharedModels
import SwiftUI

public struct ConversationClient {
  public typealias ConversationCreateHandler =
    (CreateConversation, String) -> AnyPublisher<ConversationResponse.Item, HTTPRequest.HRError>
  public typealias AddUserToConversationHandler = (AddUser, String)
    -> AnyPublisher<ConversationResponse.UserAdd, HTTPRequest.HRError>
  public typealias ConversationListHandler = (QueryItem, String) -> AnyPublisher<
    ConversationResponse, HTTPRequest.HRError
  >
  public typealias ConversationFindHandler = (String, String) -> AnyPublisher<
    ConversationResponse.Item, HTTPRequest.HRError
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
