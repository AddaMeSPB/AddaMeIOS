import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import Foundation
import WebSocketClient

extension ChatView {
  public struct ViewState: Equatable {
    public var isLoadingPage = false
    public var alert: AlertState<ChatAction>?
    public var conversation: ConversationResponse.Item?
    public var messages: IdentifiedArrayOf<ChatMessageResponse.Item> = []
    public var messageToSend = ""

    public init(
      isLoadingPage: Bool = false,
      alert: AlertState<ChatAction>? = nil,
      conversation: ConversationResponse.Item? = nil,
      messages: IdentifiedArrayOf<ChatMessageResponse.Item> = [],
      messageToSend: String = ""
    ) {
      self.isLoadingPage = isLoadingPage
      self.alert = alert
      self.conversation = conversation
      self.messages = messages
      self.messageToSend = messageToSend
    }
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case conversation(ConversationResponse.Item?)
    case messages(Result<ChatMessageResponse, HTTPError>)
    case fetchMoreMessagIfNeeded(currentItem: ChatMessageResponse.Item?)
    case message(index: String?, action: MessageAction)
    case sendResponse(NSError?)
    case webSocket(WebSocketClient.Action)
    case pingResponse(NSError?)
    case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
    case messageToSendChanged(String)
    case sendButtonTapped
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
      VStack {
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
          .listStyle(.plain)
          .scaleEffect(x: 1, y: -1, anchor: .center)
          .offset(x: 0, y: 2)
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
        .navigationBarTitle(viewStore.state.conversation?.title ?? "", displayMode: .inline)
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)

      ChatBottomView(store: store)
    }

  }
}

// struct ChatView_Previews: PreviewProvider {
//
//  static let env = ChatEnvironment(
//    chatClient: .happyPath,
//    websocket: .init(
//      websocketClient: .happyPath,
//      mainQueue: .immediate)
//    ,
//    mainQueue: .immediate
//  )
//
//  static let store = Store(
//    initialState: ChatState(),
//    reducer: chatReducer,
//    environment: env
//  )
//
//  static var previews: some View {
//    ChatView(store: store)
//  }
//
// }
