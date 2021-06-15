//
//  ConversationState.swift
//  
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import Foundation
import ComposableArchitecture
import SharedModels
import ChatView
import ContactsView

public struct ConversationsState: Equatable {

  public init(
    isLoadingPage: Bool = false,
    canLoadMorePages: Bool = true,
    currentPage: Int = 1,
    alert: AlertState<ConversationsAction>? = nil,
    conversations: IdentifiedArrayOf<ConversationResponse.Item> = [],
    conversation: ConversationResponse.Item? = nil,
    chatState: ChatState? = nil,
    contactsState: ContactsState? = nil,
    createConversation: CreateConversation? = nil
  ) {
    self.isLoadingPage = isLoadingPage
    self.canLoadMorePages = canLoadMorePages
    self.currentPage = currentPage
    self.alert = alert
    self.conversations = conversations
    self.conversation = conversation
    self.chatState = chatState
    self.contactsState = contactsState
    self.createConversation = createConversation
  }

  public var isLoadingPage = false
  public var canLoadMorePages = true
  public var currentPage = 1

  public var alert: AlertState<ConversationsAction>?
  public var conversations: IdentifiedArrayOf<ConversationResponse.Item> = []
  public var conversation: ConversationResponse.Item?
  public var createConversation: CreateConversation?
  public var chatState: ChatState?
  public var contactsState: ContactsState?

  public var isSheetPresented: Bool { self.contactsState != nil }

}

extension ConversationsState {
  var view: ConversationsView.ViewState {
    ConversationsView.ViewState(
      alert: self.alert,
      conversations: self.conversations,
      conversation: self.conversation,
      chatState: self.chatState,
      contactsState: self.contactsState
    )
  }
}

extension ConversationsState {
  public static let placholderConversations = Self(
    isLoadingPage: true,
    conversations: .init(
      [
        ConversationResponse.Item(
          Conversation(
            id: UUID().uuidString, title: "Walk Around 🚶🏽🚶🏼‍♀️",
            type: .group, createdAt: Date(), updatedAt: Date()
          )
        ),
        ConversationResponse.Item(
          Conversation(
            id: UUID().uuidString, title: "+79218821217, Alla Fake Number Update",
            type: .oneToOne, createdAt: Date(), updatedAt: Date()
          )
        ),
        ConversationResponse.Item(
          Conversation(id: UUID().uuidString, title: "Running", type: .group, createdAt: Date(), updatedAt: Date())
        )
      ]
    ),
    conversation: .init(
      Conversation(id: UUID().uuidString, title: "Running", type: .group, createdAt: Date(), updatedAt: Date())
    ),
    chatState: .init()
  )
}
