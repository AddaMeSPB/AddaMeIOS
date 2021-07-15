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

import WebSocketClient
import WebSocketClientLive

import CoreDataStore
import CoreData

public let contactsReducer: Reducer<ContactsState, ContactsAction, ContactsEnvironment> = .combine(

  contactRowReducer
    .forEach(
      state: \ContactsState.contacts,
      action: /ContactsAction.contact(id:action:),
      environment: { _ in ContactRowEnvironment() }
    ),

  .init { state, action, environment in

    switch action {

    case .onAppear:
      state.isLoading = true

      return environment.coreDataClient.contactClient.authorization()
        .map(ContactsAction.contactsAuthorizationStatus)
        .eraseToEffect()

    case .alertDismissed:
      state.alert = nil
      return .none

    case .contactsResponse(.success(let contacts)):
      print(#line, contacts)
      state.isLoading = false

      let contactRowStates = contacts.map { ContactRowState(contact: $0) }
      state.contacts = .init(contactRowStates)
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

    case .contactsAuthorizationStatus(_):
      return .none

    case let .contact(id: id, action: action):
      return .none

    case let .moveToChatRoom(present):
      return .none

    case let .chatWith(name: name, phoneNumber: phoneNumber):
      return .none

    }
  }
)

extension Reducer {
  func optional() -> Reducer<State?, Action, Environment> {
    .init { state, action, environment in
      guard var wrappedState = state
      else { return .none }
      defer { state = wrappedState }
      return self.run(&wrappedState, action, environment)
    }
  }
}
