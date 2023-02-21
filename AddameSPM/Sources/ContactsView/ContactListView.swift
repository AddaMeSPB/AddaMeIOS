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
import Contacts
import CoreData
import CoreDataClient
import CoreDataStore
import Foundation

import AddaSharedModels
import SwiftUI
import SwiftUIExtension

struct ContactListView: View {
  @Environment(\.colorScheme) var colorScheme
  public let store: StoreOf<ContactsReducer>

  public init(store: StoreOf<ContactsReducer>) {
    self.store = store
  }

  public var body: some View {
      WithViewStore(self.store, observe: { $0 }) { _ in
      ForEachStore(
        self.store.scope(
          state: \.contacts,
          action: ContactsReducer.Action.contact(id:action:)
        ),
        content: ContactRowView.init(store:)
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
