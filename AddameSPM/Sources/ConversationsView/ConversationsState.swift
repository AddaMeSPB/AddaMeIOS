//
//  ConversationState.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import ChatView
import ComposableArchitecture
import ContactsView
import Foundation
import AddaSharedModels

public struct ConversationsState: Equatable {
  public init(
    isLoadingPage: Bool = false,
    canLoadMorePages: Bool = true,
    currentPage: Int = 1,
    alert: AlertState<ConversationsAction>? = nil,
    conversations: IdentifiedArrayOf<ConversationOutPut> = [],
    conversation: ConversationOutPut? = nil,
    chatState: ChatState? = nil,
    contactsState: ContactsState? = nil,
    createConversation: ConversationCreate? = nil
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
  public var conversations: IdentifiedArrayOf<ConversationOutPut> = []
  public var conversation: ConversationOutPut?
  public var createConversation: ConversationCreate?
  public var chatState: ChatState?
  public var contactsState: ContactsState?

  public var isSheetPresented: Bool { contactsState != nil }
}

extension ConversationsState {
  public static let placholderConversations = Self(
    isLoadingPage: true,
    conversations: .init(uniqueElements: ConversationOutPut.conversationsMock),
    chatState: .init()
  )
}
