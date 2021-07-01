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

extension ContactsView {
  public struct ViewState: Equatable {
    public var alert: AlertState<ContactsAction>?
    public var contacts: IdentifiedArrayOf<Contact> = []
    public var isAuthorizedContacts: Bool = false
    public var invalidPermission: Bool = false
    public var isLoading: Bool = false
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case contactRow(id: String?, action: ContactRowAction)
    case contactsAuthorizationStatus(CNAuthorizationStatus)
    case contactsResponse(Result<[Contact], HTTPError>)
  }
}

public struct ContactsView: View {

  public let store: Store<ContactsState, ContactsAction>

  public init(store: Store<ContactsState, ContactsAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        List {
          ContactListView(
            store: viewStore.isLoading
            ? Store(
              initialState: ContactsState.contactsPlaceholder,
              reducer: .empty,
              environment: ()
            )
            : self.store
          )
          .redacted(reason: viewStore.isLoading ? .placeholder : [])

        }
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
      .navigationBarTitle("Contacts", displayMode: .automatic)
    }
//    .navigate(
//      using: store.scope(
//        state: \.chatState,
//        action: ContactRowAction.chat
//      ),
//      destination: ChatView.init(store:),
//      onDismiss: {
//        ViewStore(store.stateless.stateless).send(.moveChatRoom(false))
//      }
//    )
  }

}

// struct ContactsView_Previews: PreviewProvider {
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
//    TabView {
//      NavigationView {
//        ContactsView(store: store)
//          .redacted(reason: .placeholder)
//          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
//          .environment(\.colorScheme, .dark)
//      }
//    }
//  }
// }
