import Combine
import ComposableArchitecture
import SwiftUI
import HttpRequest
import SharedModels
import KeychainService
import InfoPlist

// public struct WebSocketClient {
//
//  public typealias Conversations = () -> AnyPublisher<ConversationResponse.Item, Never>
//  public typealias Messages = () -> AnyPublisher<ChatMessageResponse.Item, Never>
//
//  public typealias HandShake = () -> Void
//  public typealias OnReceive = (_ incomig: Result<URLSessionWebSocketTask.Message, Error>) -> Void
//  public typealias Send = (ChatMessageResponse.Item, String) -> Void
//  public typealias OnConnect = () -> Void
//  public typealias Disconnect = () -> Void
//  public typealias HandleData = (_ data: Data) -> Void
//  public typealias HandleMessageResponse = (_ message: ChatMessageResponse.Item) -> Void
//
//  public let conversations: Conversations
//  public let messages: Messages
//
//  public let handshake: HandShake
//  public let onReceive: OnReceive
//  public let send: Send
//  public let onConnect: OnConnect
//  public let disconnect: Disconnect
//  public let handleData: HandleData
//  public let handleMessageResponse: HandleMessageResponse
//
//  private let urlSession = URLSession(configuration: .default)
//  public var socket: URLSessionWebSocketTask!
//
//  public init(
//    conversations: @escaping Conversations,
//    messages: @escaping Messages,
//    handshake: @escaping HandShake,
//    onReceive: @escaping OnReceive,
//    send: @escaping Send,
//    onConnect: @escaping OnConnect,
//    disconnect: @escaping Disconnect,
//    handleData: @escaping HandleData,
//    handleMessageResponse: @escaping HandleMessageResponse
//  ) {
//    self.conversations = conversations
//    self.messages = messages
//    self.handshake = handshake
//    self.onReceive = onReceive
//    self.send = send
//    self.onConnect = onConnect
//    self.disconnect = disconnect
//    self.handleData = handleData
//    self.handleMessageResponse = handleMessageResponse
//  }
//
// }
//
// swiftlint:disable all
// let user = User(id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217", createdAt: Date(), updatedAt: Date())
// let user1 = User(id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219", createdAt: Date(), updatedAt: Date())
// let user2 = User(id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216", createdAt: Date(), updatedAt: Date())
// let lastMsg = ChatMessageResponse.Item(id: "5fb39d4e5d487e3c10c263a9", conversationId: "5fabcd48f4271d1963025d4f", messageBody: "Awesome 👏🏻", sender: user, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date())
// let conversation = Conversation(
//  id: "5fabcd48f4271d1963025d4f",
//  title: "Walk Around 🚶🏽🚶🏼‍♀️",
//  type: .group,
//  members: [user, user1, user2],
//  admins: [user] ,
//  lastMessage: lastMsg ,
//  createdAt: Date(),
//  updatedAt: Date()
// )
// let conversationItem = ConversationResponse.Item(conversation)
//
// extension WebSocketClient {
//
//  public static let happyPath = Self(
//    conversations: {
//      Just(conversationItem).eraseToAnyPublisher()
//    },
//    messages: {
//      Just(lastMsg).eraseToAnyPublisher()
//    },
//    handshake: { } ,
//    onReceive: { _ in },
//    send: { _, _ in },
//    onConnect: {},
//    disconnect: {},
//    handleData: { _ in },
//    handleMessageResponse: { _ in }
//  )
//
// }

public struct WebSocketClient {
  public init(
    cancel: @escaping (AnyHashable, URLSessionWebSocketTask.CloseCode, Data?) -> Effect<Never, Never>,
    `open`: @escaping (AnyHashable, URL, String, [String]) -> Effect<WebSocketClient.Action, Never>,
    receive: @escaping (AnyHashable) -> Effect<WebSocketClient.Message, NSError>,
    send: @escaping (AnyHashable, URLSessionWebSocketTask.Message) -> Effect<NSError?, Never>,
    sendPing: @escaping (AnyHashable) -> Effect<NSError?, Never>
  ) {
    self.cancel = cancel
    self.open = open
    self.receive = receive
    self.send = send
    self.sendPing = sendPing
  }

  public enum Action: Equatable {
    case didBecomeInvalidWithError(NSError?)
    case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    case didCompleteWithError(NSError?)
    case didOpenWithProtocol(String?)
  }

  public enum Message: Equatable {
    case data(Data)
    case string(String)

    public init?(_ message: URLSessionWebSocketTask.Message) {
      switch message {
      case let .data(data):
        self = .data(data)
      case let .string(string):
        self = .string(string)
      @unknown default:
        return nil
      }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case let (.data(lhs), .data(rhs)):
        return lhs == rhs
      case let (.string(lhs), .string(rhs)):
        return lhs == rhs
      case (.data, _), (.string, _):
        return false
      }
    }
  }

  public var cancel: (AnyHashable, URLSessionWebSocketTask.CloseCode, Data?) -> Effect<Never, Never>
  public var `open`: (AnyHashable, URL, String, [String]) -> Effect<Action, Never>
  public var receive: (AnyHashable) -> Effect<Message, NSError>
  public var send: (AnyHashable, URLSessionWebSocketTask.Message) -> Effect<NSError?, Never>
  public var sendPing: (AnyHashable) -> Effect<NSError?, Never>
}
