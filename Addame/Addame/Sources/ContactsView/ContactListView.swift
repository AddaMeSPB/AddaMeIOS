//
//  ContactListView.swift
//
//
//  Created by Saroar Khandoker on 12.06.2021.
//

import AsyncImageLoder
import ChatView
import Combine
import CombineContacts
import ComposableArchitecture
import ComposableArchitectureHelpers
import ContactClient
import ContactClientLive
import Contacts
import CoreData
import CoreDataClient
import CoreDataStore
import Foundation
import HttpRequest
import SharedModels
import SwiftUI
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
