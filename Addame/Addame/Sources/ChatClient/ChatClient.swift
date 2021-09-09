import Combine
import Foundation
import FoundationExtension
import HttpRequest
import SharedModels

public struct ChatClient {
  public typealias MessageListHandler = (QueryItem, String, String) -> AnyPublisher<
    ChatMessageResponse, HTTPError
  >

  public let messages: MessageListHandler

  public init(
    messages: @escaping MessageListHandler
  ) {
    self.messages = messages
  }
}
