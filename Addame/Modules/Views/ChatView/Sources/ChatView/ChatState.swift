//
//  ChatState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import AddaMeModels
import ComposableArchitecture

public struct ChatState: Equatable {
  public var alert: AlertState<ChatAction>?
  public var conversation: ConversationResponse.Item?
  
  public init(
    alert: AlertState<ChatAction>? = nil,
    conversation: ConversationResponse.Item? = nil
  ) {
    self.alert = alert
    self.conversation = conversation
  }
}

public extension ChatState {
  var view: ChatView.ViewState {
    ChatView.ViewState(
      alert: self.alert,
      conversation: self.conversation
    )
  }
  
}
