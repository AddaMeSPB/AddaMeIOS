//
//  ConversationView.swift
//  
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import SwiftUI
import ComposableArchitecture
import AddaMeModels
import AsyncImageLoder
import SwiftUIExtension
import FuncNetworking

extension ConversationView {
  public struct ViewState: Equatable {
    public init(
      alert: AlertState<ConversationsAction>? = nil,
      isLoadingPage: Bool = false,
      conversations: IdentifiedArrayOf<ConversationResponse.Item> = [],
      conversation: ConversationResponse.Item? = nil,
      chatState: ChatState? = nil
    ) {
      self.alert = alert
      self.isLoadingPage = isLoadingPage
      self.conversations = conversations
      self.conversation = conversation
      self.chatState = chatState
    }
    
    public var alert: AlertState<ConversationsAction>? = nil
    public var isLoadingPage = false
    public var conversations: IdentifiedArrayOf<ConversationResponse.Item> = []
    public var conversation: ConversationResponse.Item?
    public var chatState: ChatState?
  }
  
  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case moveChatRoom(Bool)
    case conversationsResponse(Result<ConversationResponse, HTTPError>)
    case fetchMoreConversationIfNeeded(currentItem: ConversationResponse.Item?)
    case conversationTapped(ConversationResponse.Item)
    case chat(ChatAction)
  }
  
}


public struct ConversationView: View {
  
  public let store: Store<ConversationsState, ConversationsAction>
  
  public init(store: Store<ConversationsState, ConversationsAction>) {
    self.store = store
  }
  
  
  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: ConversationsAction.view)) { viewStore in
      
      ZStack {
        List {
          ConversationListView(
            store: viewStore.isLoadingPage
              ? Store(
                initialState: ConversationsState.conversations,
                reducer: .empty,
                environment: ()
              )
              : self.store
          )
          .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
          
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
      .navigationTitle("Chats")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          return Button(action: {
            //viewStore.send(.presentEventForm(true))
          }) {
            Image(systemName: "plus.circle")
              .font(.title)
          }
        }
      }
      .background(Color(.systemBackground))
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
      
    }
    .navigate(
      using: store.scope(
        state: \.chatState,
        action: ConversationsAction.chat
      ),
      destination: ChatView.init(store:),
      onDismiss: {
        ViewStore(store.stateless).send(.moveChatRoom(false))
      }
    )
    
  }
}

struct ConversationView_Previews: PreviewProvider {
  
  static let environment = ConversationEnvironment(conversationClient: .happyPath, mainQueue: .immediate)
  
  static let store = Store(
    initialState: ConversationsState.conversations,
    reducer: conversationReducer,
    environment: environment
  )
  
  static var previews: some View {
    TabView {
      NavigationView {
        ConversationView(store: store)
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
          Button(action: {
            viewStore.send(.conversationTapped(conversationViewStore.state) )
            viewStore.send(.moveChatRoom(true) )
          } ) {
            ConversationRow(store: conversationStore)
              .onAppear {
                viewStore.send(.fetchMoreConversationIfNeeded(currentItem: conversationViewStore.state) )
              }
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
    WithViewStore(self.store) { viewStore  in
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
            
            if viewStore.lastMessage != nil {
              Text(viewStore.lastMessage!.messageBody).lineLimit(1)
            }
          }
          .padding(5)
          
          Spacer(minLength: 3)
          
          VStack(alignment: .trailing, spacing: 5) {
            if viewStore.lastMessage != nil {
              Text("\(viewStore.lastMessage!.createdAt?.dateFormatter ?? String.empty)")
            }
            
            if viewStore.lastMessage?.messageBody != String.empty {
              //Text("6").padding(8).background(Color("bg"))
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

public struct ConversationList:  Identifiable, Equatable {
  public init(id: String, conversation: ConversationResponse.Item) {
    self.id = id
    self.conversation = conversation
  }
  
  public let id: String
  public let conversation: ConversationResponse.Item
}

public struct MessageList: Identifiable, Equatable {
  
  public init(id: String = "", messages: [ChatMessageResponse.Item] = [] ) {
    self.id = id
    self.messages = messages
  }
  
  public var id = ""
  public var messages = [ChatMessageResponse.Item]()
}
