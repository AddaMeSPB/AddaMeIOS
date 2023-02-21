//
//  ConversationAction.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import ChatView
import ComposableArchitecture
import ContactsView
import Foundation

import AddaSharedModels
import BSON

extension Conversations.Action {
    // swiftlint:disable cyclomatic_complexity
    init(_ action: ConversationsView.ViewAction) {
        switch action {
        case .onAppear:
            self = .onAppear
        case .onDisAppear:
            self = .onDisAppear
        case let .conversationsResponse(res):
            self =  .conversationsResponse(res)
        case let .fetchMoreConversationIfNeeded(currentItem):
            self =  .fetchMoreConversationIfNeeded(currentItem: currentItem)
        case .alertDismissed:
            self = .alertDismissed
        case let .conversationTapped(conversationItem):
            self = .conversationTapped(conversationItem)
        case let .chat(action):
            self = .chat(action)
        case let .contacts(action):
            self = .contacts(action)
        case let .chatView(isPresented: isPresented):
            self = .chatView(isPresented: isPresented)
        case let .contactsView(isPresented: isPresented):
            self = .contactsView(isPresented: isPresented)
        case let .updateLastConversation(messageItem):
            self =  .updateLastConversation(messageItem)
        }
    }
}
