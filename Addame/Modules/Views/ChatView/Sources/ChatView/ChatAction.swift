//
//  ChatAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import AddaMeModels

public enum ChatAction: Equatable {
  case alertDismissed
  case conversation(ConversationResponse.Item?)
}

public extension ChatAction {
  static func view(_ localAction: ChatView.ViewAction) -> Self {
    switch localAction {
      
    case .alertDismissed:
      return .alertDismissed
    case .conversation(let conversation):
      return .conversation(conversation)
    }
  }
}


//public extension ProfileAction {
//  static func view(_ localAction: ProfileView.ViewAction) -> Self {
