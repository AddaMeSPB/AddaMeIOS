//
//  ContactsReducer.swift
//  
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import SwiftUI
import SharedModels
import HttpRequest
import ChatView

import ChatClient
import ChatClientLive

import WebsocketClient
import WebsocketClientLive

import CoreDataStore
import CoreData

public let contactsReducer = Reducer<ContactsState, ContactsAction, ContactsEnvironment> { state, action, environment in
  
  switch action {
  
  case .onAppear:
    state.isLoading = true
    
    return environment.coreDataClient.contactClient.authorization()
      .map(ContactsAction.contactsAuthorizationStatus)
      .eraseToEffect()
    
  case .alertDismissed:
    state.alert = nil
    return .none
    
  case .moveChatRoom(let present):
    state.isActivityIndicatorVisible = present
    return .none
    
  case .contactsResponse(.success(let contacts)):
    print(#line, contacts)
    state.isLoading = false
    state.contacts = .init(contacts)
    return .none
    
  case .contactsResponse(.failure(let error)):
    state.alert = .init(title: TextState("Something went worng please try again \(error.description)") )
    return .none
    
  case .contactsAuthorizationStatus(.notDetermined):
    state.alert = .init(title: TextState("Permission notDetermined"))
    return .none
    
  case .contactsAuthorizationStatus(.denied):
    state.alert = .init(title: TextState("Permission denied"))
    return .none
    
  case .contactsAuthorizationStatus(.restricted):
    state.alert = .init(title: TextState("Permission restricted"))
    
    return .none
    
  case .contactsAuthorizationStatus(.authorized):
    
    return environment.coreDataClient.getContacts()
        .subscribe(on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(ContactsAction.contactsResponse)
    

  case .chat(_):
    return .none
    
  case .contactsAuthorizationStatus(_):
    return .none
  
  case .chatRoom(index: let index, action: let action):
    return .none

  case .chatWith(name: let name, phoneNumber: let phoneNumber):
    
    return .none
  }

}
//.presents(
//  chatReducer,
//  state: \.chatState,
//  action: /ContactsAction.chat,
//  environment: {
//    ChatEnvironment(
//      chatClient: ChatClient.live(api: .build),
//      websocket: WebsocketEnvironment(
//        websocketClient: WebsocketClient.live(api: .build),
//        mainQueue: $0.mainQueue
//      ),
//      mainQueue: $0.mainQueue
//    )
//  }
//)
