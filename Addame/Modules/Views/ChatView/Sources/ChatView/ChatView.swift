import ComposableArchitecture
import SwiftUI

public struct ChatView: View {
  public init(store: Store<ChatState, ChatAction>) {
    self.store = store
  }
  
  let store: Store<ChatState, ChatAction>
  
  public var body: some View {
    VStack {
      Text("Hello, world! I am ChatView")
        .background(Color.red)
        .padding()
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
    ChatView(store: store)
  }
  
}
