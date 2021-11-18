import Combine
import Foundation
import FoundationExtension
import HTTPRequestKit
import SharedModels

public struct ChatClient {
  public typealias MessageListHandler = (QueryItem, String, String) -> AnyPublisher<
    ChatMessageResponse, HTTPRequest.HRError
  >

  public let messages: MessageListHandler

  public init(
    messages: @escaping MessageListHandler
  ) {
    self.messages = messages
  }
}
