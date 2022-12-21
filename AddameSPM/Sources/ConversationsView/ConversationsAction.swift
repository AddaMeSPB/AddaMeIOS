////
////  ConversationAction.swift
////
////
////  Created by Saroar Khandoker on 19.04.2021.
////
//
// import ChatView
// import ComposableArchitecture
// import ContactsView
// import Foundation
// import HTTPRequestKit
// import AddaSharedModels
// import BSON
//
// public enum ConversationsAction: Equatable {
//  case onAppear
//  case onDisAppear
//  case alertDismissed
//  case chatRoom(index: ObjectId, action: ConversationAction)
//  case conversationTapped(ConversationOutPut)
//  case chatView(isPresented: Bool)
//  case contactsView(isPresented: Bool)
//  case chat(ChatAction)
//  case contacts(ContactsAction)
//
//  case conversationsResponse(ConversationsResponse)
//  case conversationsResponseError(HTTPRequest.HRError)
//  case updateLastConversation(MessageItem)
//
//  case conversationResponse(Result<ConversationOutPut, HTTPRequest.HRError>)
//  case fetchMoreConversationIfNeeded(currentItem: ConversationOutPut?)
// }
//
// extension ConversationsAction {
//  // swiftlint:disable cyclomatic_complexity
//  init(_ action: ConversationsView.ViewAction) {
//    switch action {
//    case .onAppear:
//        self = .onAppear
//    case .onDisAppear:
//        self = .onDisAppear
//    case let .conversationsResponse(res):
//        self =  .conversationsResponse(res)
//    case let .conversationsResponseError(error):
//        self = .conversationsResponseError(error)
//    case let .fetchMoreConversationIfNeeded(currentItem):
//        self =  .fetchMoreConversationIfNeeded(currentItem: currentItem)
//    case .alertDismissed:
//        self = .alertDismissed
//    case let .conversationTapped(conversationItem):
//        self = .conversationTapped(conversationItem)
//    case let .chat(action):
//        self = .chat(action)
//    case let .contacts(action):
//        self = .contacts(action)
//    case let .chatView(isPresented: isPresented):
//      self = .chatView(isPresented: isPresented)
//    case let .contactsView(isPresented: isPresented):
//      self = .contactsView(isPresented: isPresented)
//    case let .updateLastConversation(messageItem):
//        self =  .updateLastConversation(messageItem)
//    }
//  }
// }
//
// public enum ConversationAction: Equatable {
//  case chat(ChatAction)
// }
