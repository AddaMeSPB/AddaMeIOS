import Combine
import Foundation
import FuncNetworking
import AddaMeModels
import FoundationExtension

public struct ChatClient {
  
  public typealias MessageListHandler = (QueryItem, String, String) -> AnyPublisher<ChatMessageResponse, HTTPError>
  
  public let messages: MessageListHandler
  
  public init(
    messages: @escaping MessageListHandler
  ) {
    self.messages = messages
  }
}
