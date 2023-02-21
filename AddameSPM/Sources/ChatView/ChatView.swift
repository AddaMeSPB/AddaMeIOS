import Foundation
import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import WebSocketReducer

extension ChatView {
    public struct ViewState: Equatable {
        public var isLoadingPage = false
        public var alert: AlertState<Chat.Action>?
        public var conversation: ConversationOutPut?
        public var messages: IdentifiedArrayOf<MessageItem> = []
        public var lastMessageItem: MessageItem?

        public init(state: Chat.State) {
            self.isLoadingPage = state.isLoadingPage
            self.alert = state.alert
            self.conversation = state.conversation
            self.messages = state.messages
            self.lastMessageItem = state.messageItem
        }
    }

    public enum ViewAction: Equatable {
        case onAppear
        case alertDismissed
        case fetchMoreMessageIfNeeded(currentItem: MessageItem?)
        case fetchMoreMessage(currentItem: MessageItem)
        case message(index: MessageItem.ID, action: ChatRow.Action)
        case messagesResponse(TaskResult<MessagePage>)
        case webSocketReducer(WebSocketReducer.Action)
        case chatButtom(ChatBottom.Action)
    }
}

public struct ChatView: View {
    public let store: StoreOf<Chat>

    public init(store: StoreOf<Chat>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store.scope(state: ViewState.init(state:), action: Chat.Action.view)) { viewStore in
            VStack {
                ZStack {
                    List {
                        ChatListView(
                            store: viewStore.isLoadingPage
                            ? Store(
                                initialState: Chat.State.placeholderMessages,
                                reducer: Chat()
                            )
                            : self.store
                        )
                        .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])
                    }
                    .listStyle(PlainListStyle())
                    .scaleEffect(x: 1, y: -1, anchor: .center)
                    .offset(x: 0, y: 2)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
            .navigationBarTitle(viewStore.state.conversation?.title ?? "", displayMode: .inline)

            ChatBottomView(store: self.store.scope(state: \.chatButtomState, action: Chat.Action.chatButtom))
        }
        .padding(.bottom, 20)
    }
}

struct ChatView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Chat.State(
            conversation: .walkAroundDraff,
            currentUser: .withFirstName,
            websocketState: .init(user: .withFirstName)
        ),
        reducer: Chat()
    )

    static var previews: some View {
        ChatView(store: store)
    }
}
