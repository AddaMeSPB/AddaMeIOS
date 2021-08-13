//
//  ContactListView.swift
//  
//
//  Created by Saroar Khandoker on 12.06.2021.
//

import ComposableArchitecture
import SwiftUI
import Contacts
import Foundation
import Combine
import CoreData

import CoreDataStore
import SharedModels
import HttpRequest
import ChatView
import AsyncImageLoder
import ContactClient
import ContactClientLive
import CombineContacts
import CoreDataClient
import ComposableArchitectureHelpers
import SwiftUIExtension

struct ContactListView: View {

  @Environment(\.colorScheme) var colorScheme
  public let store: Store<ContactsState, ContactsAction>

  public init(store: Store<ContactsState, ContactsAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { _ in
      ForEachStore(
        self.store.scope(
          state: \.contacts,
          action: ContactsAction.contact(id:action:)
        ), content: ContactRow.init(store:)
      )
    }
  }
}

// struct ContactListView_Previews: PreviewProvider {
//
//  static let environment = ContactsEnvironment(
//    coreDataClient: .init(contactClient: .authorized),
//    backgroundQueue: .immediate,
//    mainQueue: .immediate
//  )
//
//  static let store = Store(
//    initialState: ContactsState.contactsPlaceholder,
//    reducer: contactsReducer,
//    environment: environment
//  )
//
//  static var previews: some View {
//    ContactListView(store: store)
//  }
// }
