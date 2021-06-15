import Foundation
import Combine
import SwiftUI
import HttpRequest
import SharedModels
import KeychainService
import InfoPlist

public struct WebsocketClient {

  public typealias Conversations = () -> AnyPublisher<ConversationResponse.Item, Never>
  public typealias Messages = () -> AnyPublisher<ChatMessageResponse.Item, Never>

  public typealias HandShake = () -> Void
  public typealias OnReceive = (_ incomig: Result<URLSessionWebSocketTask.Message, Error>) -> Void
  public typealias Send = (ChatMessageResponse.Item, String) -> Void
  public typealias OnConnect = () -> Void
  public typealias Disconnect = () -> Void
  public typealias HandleData = (_ data: Data) -> Void
  public typealias HandleMessageResponse = (_ message: ChatMessageResponse.Item) -> Void

  public let conversations: Conversations
  public let messages: Messages

  public let handshake: HandShake
  public let onReceive: OnReceive
  public let send: Send
  public let onConnect: OnConnect
  public let disconnect: Disconnect
  public let handleData: HandleData
  public let handleMessageResponse: HandleMessageResponse

//  private let urlSession = URLSession(configuration: .default)
//  public var socket: URLSessionWebSocketTask!

  public init(
    conversations: @escaping Conversations,
    messages: @escaping Messages,
    handshake: @escaping HandShake,
    onReceive: @escaping OnReceive,
    send: @escaping Send,
    onConnect: @escaping OnConnect,
    disconnect: @escaping Disconnect,
    handleData: @escaping HandleData,
    handleMessageResponse: @escaping HandleMessageResponse
  ) {
    self.conversations = conversations
    self.messages = messages
    self.handshake = handshake
    self.onReceive = onReceive
    self.send = send
    self.onConnect = onConnect
    self.disconnect = disconnect
    self.handleData = handleData
    self.handleMessageResponse = handleMessageResponse
  }

}

// swiftlint:disable all
let user = User(id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217", createdAt: Date(), updatedAt: Date())
let user1 = User(id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219", createdAt: Date(), updatedAt: Date())
let user2 = User(id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216", createdAt: Date(), updatedAt: Date())
let lastMsg = ChatMessageResponse.Item(id: "5fb39d4e5d487e3c10c263a9", conversationId: "5fabcd48f4271d1963025d4f", messageBody: "Awesome 👏🏻", sender: user, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date())
let conversation = Conversation(
  id: "5fabcd48f4271d1963025d4f",
  title: "Walk Around 🚶🏽🚶🏼‍♀️",
  type: .group,
  members: [user, user1, user2],
  admins: [user] ,
  lastMessage: lastMsg ,
  createdAt: Date(),
  updatedAt: Date()
)
let conversationItem = ConversationResponse.Item(conversation)

extension WebsocketClient {

  public static let happyPath = Self(
    conversations: {
      Just(conversationItem).eraseToAnyPublisher()
    },
    messages: {
      Just(lastMsg).eraseToAnyPublisher()
    },
    handshake: { } ,
    onReceive: { _ in },
    send: { _, _ in },
    onConnect: {},
    disconnect: {},
    handleData: { _ in },
    handleMessageResponse: { _ in }
  )

}
