//
//  ConversationsView.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import AsyncImageLoder
import ChatView
import ComposableArchitecture
import ComposablePresentation
import ComposableArchitectureHelpers
import ContactsView
import HTTPRequestKit
import SharedModels
import SwiftUI
import SwiftUIExtension

extension ConversationsView {
  public struct ViewState: Equatable {
    public init(
      alert: AlertState<ConversationsAction>? = nil,
      isLoadingPage: Bool = false,
      conversations: IdentifiedArrayOf<ConversationResponse.Item> = [],
      conversation: ConversationResponse.Item? = nil,
      chatState: ChatState? = nil,
      contactsState: ContactsState? = nil,
      createConversation: CreateConversation? = nil
    ) {
      self.alert = alert
      self.isLoadingPage = isLoadingPage
      self.conversations = conversations
      self.conversation = conversation
      self.chatState = chatState
      self.contactsState = contactsState
      self.createConversation = createConversation
    }

    public var alert: AlertState<ConversationsAction>?
    public var isLoadingPage = false
    public var conversations: IdentifiedArrayOf<ConversationResponse.Item> = []
    public var conversation: ConversationResponse.Item?
    public var chatState: ChatState?
    public var contactsState: ContactsState?
    public var isSheetPresented: Bool { contactsState != nil }
    public var createConversation: CreateConversation?
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case chatView(isPresented: Bool)
    case contactsView(isPresented: Bool)
    case conversationsResponse(Result<ConversationResponse, HTTPRequest.HRError>)
    case fetchMoreConversationIfNeeded(currentItem: ConversationResponse.Item?)
    case conversationTapped(ConversationResponse.Item)
    case chat(ChatAction)
    case contacts(ContactsAction)
  }
}

public struct ConversationsView: View {
  @State private var showingSheet = false
  public let store: Store<ConversationsState, ConversationsAction>

  public init(store: Store<ConversationsState, ConversationsAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: ConversationsAction.view
      )
    ) { viewStore in

      ZStack(alignment: .center) {
        List {
          ConversationListView(
            store: viewStore.isLoadingPage
              ? Store(
                initialState: ConversationsState.placholderConversations,
                reducer: .empty,
                environment: ()
              )
              : self.store
          )
          .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
        }
      }
      .onAppear {
        ViewStore(store.stateless).send(.onAppear)
      }
      .navigationTitle("Chats")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewStore.send(.contactsView(isPresented: true))
          } label: {
            if #available(iOS 15.0, *) {
              Image(systemName: "bubble.left.and.bubble.right")
                .opacity(viewStore.isSheetPresented ? 0 : 1)
                .overlay(ProgressView().opacity(viewStore.isSheetPresented ? 1 : 0) )
            } else {
              Image(systemName: "square.and.pencil")
                .opacity(viewStore.isSheetPresented ? 0 : 1)
            }
          }
        }
      }
      .background(Color(.systemBackground))
      .alert(self.store.scope(state: { $0.alert }), dismiss: ConversationsAction.alertDismissed)
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .sheet(
      store.scope(state: \.contactsState, action: ConversationsAction.contacts),
      mapState: replayNonNil(),
      onDismiss: { ViewStore(store.stateless).send(.contactsView(isPresented: false)) },
      content: ContactsView.init(store:)
    )
    .background(
      NavigationLinkWithStore(
        store.scope(state: \.chatState, action: ConversationsAction.chat),
        mapState: replayNonNil(),
        onDeactivate: { ViewStore(store.stateless).send(.chatView(isPresented: false)) },
        destination: ChatView.init(store:)
      )
    )
  }
}

struct ConversationsView_Previews: PreviewProvider {
  static let environment = ConversationEnvironment(
    conversationClient: .happyPath,
    websocketClient: .live,
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: ConversationsState.placholderConversations,
    reducer: conversationsReducer,
    environment: environment
  )

  static var previews: some View {
    TabView {
      NavigationView {
        ConversationsView(store: store)
          //          .redacted(reason: .placeholder)
          //          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
          .environment(\.colorScheme, .dark)
      }
    }
  }
}

public struct ConversationListView: View {
  public let store: Store<ConversationsState, ConversationsAction>

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      ForEachStore(
        self.store.scope(state: \.conversations, action: ConversationsAction.chatRoom)
      ) { conversationStore in
        WithViewStore(conversationStore) { conversationViewStore in

          Button {
            viewStore.send(.conversationTapped(conversationViewStore.state))
          } label: {
            ConversationRow(store: conversationStore)
            // .onAppear {
            //   viewStore.send(
            //     .fetchMoreConversationIfNeeded(
            //       currentItem: conversationViewStore.state
            //     )
            //   )
            // }
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
    }
  }
}

struct ConversationRow: View {
  @Environment(\.colorScheme) var colorScheme
  public let store: Store<ConversationResponse.Item, ConversationAction>

  public init(store: Store<ConversationResponse.Item, ConversationAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        HStack(spacing: 0) {
          if viewStore.lastMessage?.sender.avatarUrl != nil {
            AsyncImage(
              urlString: viewStore.lastMessage?.sender.avatarUrl,
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
            Text(viewStore.title)
              .lineLimit(1)
              .font(.system(size: 18, weight: .semibold, design: .rounded))
              .foregroundColor(Color(.systemBlue))

            if let lmsg = viewStore.lastMessage {
              Text(lmsg.messageBody).lineLimit(1)
            }
          }
          .padding(5)

          Spacer(minLength: 3)

          VStack(alignment: .trailing, spacing: 5) {
            if let lmsg = viewStore.lastMessage {
              Text("\(lmsg.createdAt?.dateFormatter ?? String.empty)")
            }

            if viewStore.lastMessage?.messageBody != String.empty {
              // Text("6").padding(8).background(Color("bg"))
              //  .foregroundColor(.white).clipShape(Circle())
            } else {
              Spacer()
            }
          }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
        .padding(2)
      }
    }
  }
}

public struct ConversationList: Identifiable, Equatable {
  public init(id: String, conversation: ConversationResponse.Item) {
    self.id = id
    self.conversation = conversation
  }

  public let id: String
  public let conversation: ConversationResponse.Item
}

public struct MessageList: Identifiable, Equatable {
  public init(id: String = "", messages: [ChatMessageResponse.Item] = []) {
    self.id = id
    self.messages = messages
  }

  public var id = ""
  public var messages = [ChatMessageResponse.Item]()
}
