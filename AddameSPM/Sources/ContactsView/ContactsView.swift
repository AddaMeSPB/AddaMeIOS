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
import ContactClient

extension ContactsView {
    public struct ViewState: Equatable {
        public var alert: AlertState<ContactsReducer.Action>?
        public var contacts: IdentifiedArrayOf<ContactRow.State>
        public var isAuthorizedContacts: Bool = false
        public var invalidPermission: Bool = false
        public var isLoading: Bool = false
        public var isActivityIndicatorVisible: Bool = false

        public init(state: ContactsReducer.State) {
//            self.alert = state.alert
            self.contacts = state.contacts
            self.isAuthorizedContacts = state.isAuthorizedContacts
            self.invalidPermission = state.invalidPermission
            self.isLoading = state.isLoading
            self.isActivityIndicatorVisible = state.isActivityIndicatorVisible
        }

      }

      public enum ViewAction: Equatable {
        case onAppear
        case alertDismissed
          case contactRow(id: String?, action: ContactRow.Action)
        case contactsAuthorizationStatus(CNAuthorizationStatus)
        case contactsResponse(TaskResult<[ContactOutPut]>)
      }
}

public struct ContactsView: View {
  public let store: StoreOf<ContactsReducer>

  public init(store: StoreOf<ContactsReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store, observe: ViewState.init, send: ContactsReducer.Action.init) { viewStore in
      ZStack {
        List {
          ContactListView(
            store: viewStore.isLoading
            ? Store.init(initialState: ContactsReducer.State.contactsPlaceholder) { ContactsReducer() }

//            Store(
//                initialState: ContactsReducer.State.contactsPlaceholder,
//                reducer: ContactsReducer()
//              )
              : self.store
          )
          .redacted(reason: viewStore.isLoading ? .placeholder : [])
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
      //.alert(self.store.scope(state: \.alert ), dismiss: .alertDismissed)
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

extension ContactsReducer.Action {
    init(action: ContactsView.ViewAction) {
        switch action {

        case .onAppear:
            self = .onAppear
        case .alertDismissed:
            self = .alertDismissed
        case .contactRow(id: let id, action: let action):
            self = .contact(id: id, action: action)
        case .contactsAuthorizationStatus(let status):
            self = .contactsAuthorizationStatus(status)
        case .contactsResponse(let response):
            self = .contactsResponse(response)
        }
    }
}

//struct ContactsView_Previews: PreviewProvider {
//
//    static let store = Store(
//        initialState: ContactsReducer.State(),
//        reducer: ContactsReducer()
//            .dependency(\.contactClient, .authorized)
//    )
//
//    static var previews: some View {
//        TabView {
//            NavigationView {
//                ContactsView(store: store)
//                    .redacted(reason: .placeholder)
////                    .redacted(reason: Events.State.events.isLoadingPage ? .placeholder : [])
//                    .environment(\.colorScheme, .dark)
//            }
//        }
//    }
//}
