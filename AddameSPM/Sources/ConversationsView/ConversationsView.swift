////
////  ConversationsView.swift
////
////
////  Created by Saroar Khandoker on 19.04.2021.
////
//
// import AsyncImageLoder
// import ChatView
// import ComposableArchitecture
// import ComposablePresentation
// import ComposableArchitectureHelpers
// import ContactsView
// import HTTPRequestKit
// import AddaSharedModels
// import SwiftUI
// import SwiftUIExtension
//
// extension ConversationsView {
//    public struct ViewState: Equatable {
//        public init(state: ConversationsState) {
//            self.alert = state.alert
//            self.isLoadingPage = state.isLoadingPage
//            self.conversations = state.conversations
//            self.conversation = state.conversation
//            self.chatState = state.chatState
//            self.contactsState = state.contactsState
//            self.createConversation = state.createConversation
//        }
//
//        public var alert: AlertState<ConversationsAction>?
//        public var isLoadingPage = false
//        public var conversations: IdentifiedArrayOf<ConversationOutPut> = []
//        public var conversation: ConversationOutPut?
//        public var chatState: ChatState?
//        public var contactsState: ContactsState?
//        public var isSheetPresented: Bool { contactsState != nil }
//        public var createConversation: ConversationCreate?
//    }
//
//    public enum ViewAction: Equatable {
//        case onAppear
//        case onDisAppear
//        case alertDismissed
//        case chatView(isPresented: Bool)
//        case contactsView(isPresented: Bool)
//        case conversationsResponse(ConversationsResponse)
//        case conversationsResponseError(HTTPRequest.HRError)
//        case fetchMoreConversationIfNeeded(currentItem: ConversationOutPut?)
//        case conversationTapped(ConversationOutPut)
//        case chat(ChatAction)
//        case contacts(ContactsAction)
//        case updateLastConversation(MessageItem)
//    }
// }
//
// public struct ConversationsView: View {
//    @State private var showingSheet = false
//    public let store: Store<ConversationsState, ConversationsAction>
//
//    public init(store: Store<ConversationsState, ConversationsAction>) {
//        self.store = store
//    }
//
//    public var body: some View {
//        WithViewStore(self.store, observe: ViewState.init, send: ConversationsAction.init) { viewStore in
//
//            ZStack(alignment: .center) {
//                List {
//                    ConversationListView(
//                        store: viewStore.isLoadingPage
//                        ? Store(
//                            initialState: ConversationsState.placholderConversations,
//                            reducer: .empty,
//                            environment: ()
//                        )
//                        : self.store
//                    )
//                    .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
//                }
//            }
//            .onDisappear {
//                ViewStore(store.stateless).send(.onDisAppear)
//            }
//            .navigationTitle("Chats")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        viewStore.send(.contactsView(isPresented: true))
//                    } label: {
//                        if #available(iOS 15.0, *) {
//                            Image(systemName: "bubble.left.and.bubble.right")
//                                .opacity(viewStore.isSheetPresented ? 0 : 1)
//                                .overlay(ProgressView().opacity(viewStore.isSheetPresented ? 1 : 0) )
//                        } else {
//                            Image(systemName: "square.and.pencil")
//                                .opacity(viewStore.isSheetPresented ? 0 : 1)
//                        }
//                    }
//                }
//            }
//            .background(Color(.systemBackground))
//            .alert(self.store.scope(state: { $0.alert }), dismiss: ConversationsAction.alertDismissed)
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .sheet(
//            store.scope(state: \.contactsState, action: ConversationsAction.contacts),
//            mapState: replayNonNil(),
//            onDismiss: { ViewStore(store.stateless).send(.contactsView(isPresented: false)) },
//            content: ContactsView.init(store:)
//        )
//        .background(
//            NavigationLinkWithStore(
//                store.scope(state: \.chatState, action: ConversationsAction.chat),
//                mapState: replayNonNil(),
//                onDeactivate: { ViewStore(store.stateless).send(.chatView(isPresented: false)) },
//                destination: ChatView.init(store:)
//            )
//        )
//    }
// }
//
// struct ConversationsView_Previews: PreviewProvider {
//    static let environment = ConversationEnvironment(
//        conversationClient: .happyPath,
//        websocketClient: .live,
//        backgroundQueue: .immediate,
//        mainQueue: .immediate
//    )
//
//    static let store = Store(
//        initialState: ConversationsState.placholderConversations,
//        reducer: conversationsReducer,
//        environment: environment
//    )
//
//    static var previews: some View {
//        TabView {
//            NavigationView {
//                ConversationsView(store: store)
//                //          .redacted(reason: .placeholder)
//                //          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
//                    .environment(\.colorScheme, .dark)
//            }
//        }
//    }
// }
//
// public struct ConversationListView: View {
//    public let store: Store<ConversationsState, ConversationsAction>
//
//    public var body: some View {
//        WithViewStore(self.store) { viewStore in
//            ForEachStore(
//                self.store.scope(state: \.conversations, action: ConversationsAction.chatRoom)
//            ) { conversationStore in
//                WithViewStore(conversationStore) { conversationViewStore in
//
//                    Button {
//                        viewStore.send(.conversationTapped(conversationViewStore.state))
//                    } label: {
//                        ConversationRow(store: conversationStore)
//                        // .onAppear {
//                        //   viewStore.send(
//                        //     .fetchMoreConversationIfNeeded(
//                        //       currentItem: conversationViewStore.state
//                        //     )
//                        //   )
//                        // }
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//            }
//        }
//    }
// }
//
// extension String {
//    var url: URL? {
//        return URL(string: self)
//    }
//
//    var urll: URL {
//        return URL(string: self)!
//    }
// }
//
// struct ConversationRow: View {
//    @Environment(\.colorScheme) var colorScheme
//    public let store: Store<ConversationOutPut, ConversationAction>
//
//    public init(store: Store<ConversationOutPut, ConversationAction>) {
//        self.store = store
//    }
//
//    public var body: some View {
//        WithViewStore(self.store) { viewStore in
//            Group {
//                HStack(spacing: 0) {
//                    if viewStore.ifAttacmentsNotEmpty {
//                        AsyncImage(
//                            url: viewStore.imageUrlString.urll,
//                            placeholder: {
//                                Text("Loading...")
//                                    .frame(width: 100, height: 100, alignment: .center)
//                            },
//                            image: { Image(uiImage: $0).resizable() }
//                        )
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 50, height: 50)
//                        .clipShape(Circle())
//                        .padding(.trailing, 5)
//                    } else {
//                        Image(systemName: "person.fill")
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(Color.backgroundColor(for: self.colorScheme))
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.blue, lineWidth: 1))
//                            .padding(.trailing, 5)
//                    }
//
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text(viewStore.title)
//                            .lineLimit(1)
//                            .font(.system(size: 18, weight: .semibold, design: .rounded))
//                            .foregroundColor(Color(.systemBlue))
//
//                        if let lmsg = viewStore.lastMessage {
//                            Text(lmsg.messageBody).lineLimit(1)
//                        }
//                    }
//                    .padding(5)
//
//                    Spacer(minLength: 3)
//
//                    VStack(alignment: .trailing, spacing: 5) {
//                        if let lmsg = viewStore.lastMessage {
//                            Text("\(lmsg.createdAt?.dateFormatter ?? String.empty)")
//                        }
//
//                        if viewStore.lastMessage?.messageBody != String.empty {
//                            // Text("6").padding(8).background(Color("bg"))
//                            //  .foregroundColor(.white).clipShape(Circle())
//                        } else {
//                            Spacer()
//                        }
//                    }
//                }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
//                .padding(2)
//            }
//        }
//    }
// }
