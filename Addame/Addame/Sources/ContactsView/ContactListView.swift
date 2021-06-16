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
    WithViewStore(self.store) { rootviewStore in
      ForEachStore(
        self.store.scope(state: \.contacts, action: ContactsAction.chatRoom)
      ) { contactStore in
        // ContactsRow(store: contactStore)

        WithViewStore(contactStore) { viewStore  in
          HStack(spacing: 0) {
              if viewStore.avatar != nil {
                AsyncImage(
                  urlString: viewStore.avatar!,
                  placeholder: {
                    Text("Loading...").frame(width: 100, height: 100, alignment: .center)
                  },
                  image: {
                    Image(uiImage: $0).resizable()
                  }
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding(.trailing, 5)
              } else {
                Image(systemName: "person.fill")
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 50, height: 50)
                  .foregroundColor(Color.backgroundColor(for: self.colorScheme))
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                  .padding(.trailing, 5)
              }

              VStack(alignment: .leading, spacing: 5) {
                Text(viewStore.phoneNumber)
                  .lineLimit(1)
                  .font(.system(size: 18, weight: .semibold, design: .rounded))
                  .foregroundColor(Color(.systemBlue))

                if viewStore.fullName != nil {
                  Text(viewStore.fullName!).lineLimit(1)
                }

              }
              .padding(5)

              Spacer()
              Button(action: {
                rootviewStore.send(.chatWith(name: viewStore.fullName ?? "unknow", phoneNumber: viewStore.phoneNumber) )
                rootviewStore.send(.moveChatRoom(true))
              }) {
                if rootviewStore.isActivityIndicatorVisible {
                  Image(systemName: "slowmo")
                } else {
                  Image(systemName: "bubble.left.and.bubble.right")
                }

              }
              .buttonStyle(BorderlessButtonStyle())

          }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
            .padding(2)
        }

      }
    }
  }
}

struct ContactListView_Previews: PreviewProvider {

  static let environment = ContactsEnvironment(
    coreDataClient: .init(contactClient: .authorized),
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: ContactsState.contactsPlaceholder,
    reducer: contactsReducer,
    environment: environment
  )

  static var previews: some View {
    ContactListView(store: store)
  }
}
