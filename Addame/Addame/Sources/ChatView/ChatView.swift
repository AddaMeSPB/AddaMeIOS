import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest

extension ChatView {
  public struct ViewState: Equatable {
    public var isLoadingPage = false
    public var alert: AlertState<ChatAction>?
    public var conversation: ConversationResponse.Item?
    public var messages: IdentifiedArrayOf<ChatMessageResponse.Item> = []

    public init(
      isLoadingPage: Bool = false,
      alert: AlertState<ChatAction>? = nil,
      conversation: ConversationResponse.Item? = nil,
      messages: IdentifiedArrayOf<ChatMessageResponse.Item> = []
    ) {
      self.isLoadingPage = isLoadingPage
      self.alert = alert
      self.conversation = conversation
      self.messages = messages
    }
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case conversation(ConversationResponse.Item?)
    case messages(Result<ChatMessageResponse, HTTPError>)
    case fetchMoreMessagIfNeeded(currentItem: ChatMessageResponse.Item?)
    case message(index: String?, action: MessageAction)
  }
}

public struct ChatView: View {

  public let store: Store<ChatState, ChatAction>

  public init(
    store: Store<ChatState, ChatAction>
  ) {
    self.store = store
  }

  public var body: some View {

    WithViewStore(self.store.scope(state: { $0.view }, action: ChatAction.view )) { viewStore  in
      ZStack {
        List {
          ChatListView(
            store: viewStore.isLoadingPage
              ? Store(
                initialState: ChatState.placeholderMessages,
                reducer: .empty,
                environment: ()
              )
              : self.store
          )
          .redacted(reason: viewStore.isLoadingPage ? .placeholder : [])

        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .navigationBarTitle(viewStore.state.conversation?.title ?? "", displayMode: .automatic)
    }
    .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
  }
}

struct ChatView_Previews: PreviewProvider {

  static let env = ChatEnvironment(
    chatClient: .happyPath,
    websocket: .init(
      websocketClient: .happyPath,
      mainQueue: .immediate)
    ,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: ChatState(),
    reducer: chatReducer,
    environment: env
  )

  static var previews: some View {
    ChatView(store: store)
  }

}
