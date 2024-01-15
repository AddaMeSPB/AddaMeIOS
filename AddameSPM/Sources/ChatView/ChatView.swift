import Foundation
import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import WebSocketReducer

extension ChatView {
    public struct ViewState: Equatable {
        public var isLoadingPage = false
        public var alert: AlertState<Chat.AlertAction>?
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

    @State private var keyboardHeight: CGFloat = 0
    public let store: StoreOf<Chat>

    public init(store: StoreOf<Chat>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                ZStack {
                    List {
                        ChatListView(
                            store: viewStore.isLoadingPage
                            ? Store(initialState: Chat.State.placeholderMessages) { Chat() }
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
            .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
            .navigationBarTitle(
                viewStore.state.conversation?.title
                ?? "",
                displayMode: .inline
            )

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
        )
    ) { Chat() }

    static var previews: some View {
        ChatView(store: store)
    }
}
