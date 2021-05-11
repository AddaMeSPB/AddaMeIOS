//
//  ChatState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SharedModels
import ComposableArchitecture

public struct ChatState: Equatable {
  var isLoadingPage = false
  var currentPage = 1
  var canLoadMorePages = true
  
  public var alert: AlertState<ChatAction>?
  public var conversation: ConversationResponse.Item?
  public var messages: IdentifiedArrayOf<ChatMessageResponse.Item> = []
  
  public init(
    isLoadingPage: Bool = false,
    alert: AlertState<ChatAction>? = nil,
    conversation: ConversationResponse.Item? = nil,
    messages: IdentifiedArrayOf<ChatMessageResponse.Item> = []
  ) {
    self.isLoadingPage = isLoadingPage
    self.alert = alert
    self.conversation = conversation
    self.messages = messages
  }
}

public extension ChatState {
  var view: ChatView.ViewState {
    ChatView.ViewState(
      isLoadingPage: self.isLoadingPage,
      alert: self.alert,
      conversation: self.conversation,
      messages: self.messages
    )
  }
}


public let user = User(id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217", createdAt: Date(), updatedAt: Date())
public let user1 = User(id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219", createdAt: Date(), updatedAt: Date())
public let user2 = User(id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216", createdAt: Date(), updatedAt: Date())

extension ChatState {
  
  public static let placeholderMessages = Self(
    isLoadingPage: true,
    messages: .init(
      arrayLiteral: ChatMessageResponse.Item(id: "5f96c378d6b5590459f0cd68", conversationId: "5f929515ba01cea941e2b2eb", messageBody: "Awesome 👏🏻", sender: user, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date()
      ),
      
      ChatMessageResponse.Item(id: "5f96c381396c401b86d6db68", conversationId: "5f929515ba01cea941e2b2eb", messageBody: "Awesome 👏🏻", sender: user, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date()
      ),
      
      ChatMessageResponse.Item(id: "5f96c4141f59a5ec9a9f9f05", conversationId: "5f929515ba01cea941e2b2eb", messageBody: "Awesome 👏🏻", sender: user2, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date()
      ),
      
      ChatMessageResponse.Item(id: "5f9712990430e512e7dbfe6b", conversationId: "5f929515ba01cea941e2b2eb", messageBody: "Awesome 👏🏻", sender: user2, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date()
      ),
      
      ChatMessageResponse.Item(id: "5f9713d8c4b1856382b7bd86", conversationId: "5f929515ba01cea941e2b2eb", messageBody: "Awesome 👏🏻", sender: user1, recipient: nil, messageType: .text, isRead: true, isDelivered: true, createdAt: Date(), updatedAt: Date()
      ),
      
      ChatMessageResponse.Item(
        id: "5f97140108b3dca8803f979e",
        conversationId: "5f929515ba01cea941e2b2eb",
        messageBody: "Awesome 👏🏻",
        sender: user1,
        recipient: nil,
        messageType: .text,
        isRead: true,
        isDelivered: true,
        createdAt: Date(),
        updatedAt: Date()
      )
    )
  )
}
