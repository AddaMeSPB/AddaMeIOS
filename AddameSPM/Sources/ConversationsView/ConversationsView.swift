//
//  ConversationsView.swift
//
//
//  Created by Saroar Khandoker on 19.04.2021.
//

import AsyncImageLoder
import ChatView
import ComposableArchitecture
import ComposableArchitectureHelpers
import ContactsView

import AddaSharedModels
import SwiftUI
import SwiftUIExtension
import NukeUI
import SwiftUIHelpers

extension ConversationsView {
    public struct ViewState: Equatable {
        public init(state: Conversations.State) {
            self.isLoadingPage = state.isLoadingPage
            self.conversations = state.conversations
            self.conversation = state.conversation
            self.chatState = state.chatState
            self.contactsState = state.contactsState
            self.createConversation = state.createConversation
        }

        public var isLoadingPage = false
        public var conversations: IdentifiedArrayOf<ConversationOutPut> = []
        public var conversation: ConversationOutPut?
        public var chatState: Chat.State?
        public var isChatViewNavigateActive: Bool { chatState != nil }
        public var contactsState: ContactsReducer.State?
        public var isSheetPresented: Bool { contactsState != nil }
        public var createConversation: ConversationCreate?
    }

    public enum ViewAction: Equatable {
        case onAppear
        case onDisAppear
        case alertDismissed
        case chatView(isPresented: Bool)
        case contactsView(isPresented: Bool)
        case conversationsResponse(TaskResult<ConversationsResponse>)
        case fetchMoreConversationIfNeeded(currentItem: ConversationOutPut?)
        case conversationTapped(ConversationOutPut)
        case chat(Chat.Action)
        case contacts(ContactsReducer.Action)
        case updateLastConversation(MessageItem)
    }
}

public struct ConversationsView: View {
    @State private var showingSheet = false
    public let store: StoreOf<Conversations>

    public init(store: StoreOf<Conversations>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: Conversations.Action.init) { viewStore in

            ZStack(alignment: .center) {
                List {
                    ConversationListView(
                        store: viewStore.isLoadingPage
                        ? Store(
                            initialState: Conversations.State.placholderConversations
                        ) {
                            Conversations()
                        }
                        : self.store
                    )
                    .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
                }
            }
            .onDisappear {
                store.send(.onDisAppear)
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
            .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isSheetPresented,
                    send:{ .contactsView(isPresented: $0) }
                )
            ) {
                IfLetStore(
                    self.store.scope(state: \.contactsState, action: Conversations.Action.contacts),
                    then: ContactsView.init(store:)
                )
            }
            .background(
                NavigationLink(
                  destination: IfLetStore(
                    self.store.scope(
                      state: \.chatState,
                      action: Conversations.Action.chat
                    )
                  ) {
                      ChatView.init(store: $0)
                  },
                  isActive: viewStore.binding(
                    get: \.isChatViewNavigateActive,
                    send: { .chatView(isPresented: $0) }
                  )
                ) {}
            )

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ConversationsView_Previews: PreviewProvider {

    static let store = Store(
        initialState: Conversations.State.placholderConversations
    ) {
        Conversations()
    }

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
    public let store: StoreOf<Conversations>

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ForEachStore(
                self.store.scope(
                    state: \.conversations,
                    action: Conversations.Action.conversation(id:action:)
                )
            ) { conversationStore in
                WithViewStore(conversationStore, observe: { $0 }) { conversationViewStore in

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

extension String {
    var url: URL? {
        return URL(string: self)
    }

    var urll: URL {
        return URL(string: self)!
    }
}

public struct Conversation: Reducer {
    public typealias State = ConversationOutPut

    public enum Action: Equatable {}

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {}
    }
}

public struct ConversationRow: View {
    @Environment(\.colorScheme) var colorScheme
    public let store: StoreOf<Conversation>

    public init(store: StoreOf<Conversation>) {
        self.store = store
    }

    public var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                HStack(spacing: 0) {
                    if viewStore.ifAttacmentsNotEmpty {

                        LazyImage(request: ImageRequest(url: viewStore.imageUrlString.urll)) { state in
                            if let image = state.image {
                                image.resizable()
                            } else if state.error != nil {
                                Color.red // Indicates an error.
                            } else {
                                Color.blue // Acts as a placeholder.
                            }
                        }
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
                        } else {
                            Text(viewStore.lastMessage?.messageBody ?? "").lineLimit(1)
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
