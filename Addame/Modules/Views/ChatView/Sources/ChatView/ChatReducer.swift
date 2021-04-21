//
//  ChatReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture

public let chatReducer = Reducer<ChatState, ChatAction, Void> { state, action, _ in
  switch action {
  
  case .alertDismissed:
    state.alert = nil
    return .none
  case .conversation(let converstion):
    state.conversation = converstion
    return .none
    
  }
}
