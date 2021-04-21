import ComposableArchitecture
import SwiftUI
import AddaMeModels

extension ChatView {
  public struct ViewState: Equatable {
    public var alert: AlertState<ChatAction>?
    public var conversation: ConversationResponse.Item?
    
    public init(alert: AlertState<ChatAction>? = nil, conversation: ConversationResponse.Item? = nil) {
      self.alert = alert
      self.conversation = conversation
    }
  }
  
  public enum ViewAction: Equatable {
    case alertDismissed
    case conversation(ConversationResponse.Item?)
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
    VStack {
      WithViewStore(self.store.scope(state: { $0.view }, action: ChatAction.view )) { viewStore  in
        Text("Hello, world! I am ChatView \(viewStore.state.conversation?.title ?? "")")
          .background(Color.red)
          .padding()
      }
      
    }
    .navigationTitle("Chats")
  }
}

struct ChatView_Previews: PreviewProvider {
  
  static let store = Store(
    initialState: ChatState(),
    reducer: chatReducer,
    environment: ()
  )
  
  static var previews: some View {
    ChatView(
      store: store
    )
  }
  
}
