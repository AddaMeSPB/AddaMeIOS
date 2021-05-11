import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import KeychainService
import AsyncImageLoder
import SwiftUIExtension

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

struct ChatListView: View {
  let store: Store<ChatState, ChatAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ForEachStore(
        self.store.scope(state: \.messages, action: ChatAction.message)
      ) { chatStore in
        WithViewStore(chatStore) { messageViewStore in
          ChatRowView(store: chatStore)
            .onAppear {
              viewStore.send(.fetchMoreMessagIfNeeded(currentItem: messageViewStore.state) )
            }
        }
      }
    }
  }
}

struct ChatRowView: View {
  
  @Environment(\.colorScheme) var colorScheme
  let store: Store<ChatMessageResponse.Item, MessageAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        
        if !currenuser(viewStore.sender.id) {
          HStack {
            Group {
              
              if viewStore.sender.avatarUrl != nil {
                AsyncImage(
                  urlString: viewStore.sender.avatarUrl,
                  placeholder: { Text("Loading...").frame(width: 40, height: 40, alignment: .center) },
                  image: {
                    Image(uiImage: $0).resizable()
                  }
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
              } else {
                Image(systemName: "person.fill")
                  .font(.title2)
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 40, height: 40)
                  .foregroundColor(Color.backgroundColor(for: self.colorScheme))
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.black, lineWidth: 1))
                
              }
              
              Text(viewStore.messageBody)
                .bold()
                .padding(10)
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .background(Color(.systemBackground))
            Spacer()
          }
          .background(Color(.systemBackground))
        } else {
          HStack {
            Group {
              Spacer()
              Text(viewStore.messageBody)
                .bold()
                .foregroundColor(Color.white)
                .padding(10)
                .background(Color.red)
                .cornerRadius(10)
              
              if viewStore.sender.avatarUrl != nil {
                AsyncImage(
                  urlString: viewStore.sender.avatarUrl,
                  placeholder: { Text("Loading...").frame(width: 40, height: 40, alignment: .center) },
                  image: {
                    Image(uiImage: $0).resizable()
                  }
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
              } else {
                Image(systemName: "person.fill")
                  .font(.title2)
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 40, height: 40)
                  .foregroundColor(Color.backgroundColor(for: self.colorScheme))
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.black, lineWidth: 1))
              }
              
            }
            
          }
          .background(Color(.systemBackground))
        }
      }
      .background(Color(.systemBackground))
    }
  }
  
  func currenuser(_ userId: String) -> Bool {
      guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
        return false
      }
      
      return currentUSER.id == userId ? true : false
      
    }
}
