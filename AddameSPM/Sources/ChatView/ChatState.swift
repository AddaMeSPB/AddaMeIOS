//
//  ChatState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import AddaSharedModels

public struct ChatState: Equatable {
  var isLoadingPage = false
  var currentPage = 1
  var canLoadMorePages = true

  public var alert: AlertState<ChatAction>?
  public var conversation: ConversationOutPut?
  public var messages: IdentifiedArrayOf<MessageItem> = []
  public var messageToSend = ""
  public var isCurrentUser = false

  public init(
    isLoadingPage: Bool = false,
    alert: AlertState<ChatAction>? = nil,
    conversation: ConversationOutPut? = nil,
    messages: IdentifiedArrayOf<MessageItem> = []
  ) {
    self.isLoadingPage = isLoadingPage
    self.alert = alert
    self.conversation = conversation
    self.messages = messages
  }
}

extension ChatState {
  public var view: ChatView.ViewState {
    ChatView.ViewState(
      isLoadingPage: isLoadingPage,
      alert: alert,
      conversation: conversation,
      messages: messages,
      messageToSend: messageToSend
    )
  }
}

extension ChatState {
  public static let placeholderMessages = Self(
    isLoadingPage: true,
    messages: .init(uniqueElements: MessagePage.draff.items)
  )
}
