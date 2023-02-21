//
//  ChatReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation
import ComposableArchitecture
import FoundationExtension
import KeychainClient
import AddaSharedModels
import BSON
import APIClient
import WebSocketReducer

public struct Chat: ReducerProtocol {

    public struct State: Equatable {
        public init(
            isLoadingPage: Bool = false,
            currentPage: Int = 1, canLoadMorePages: Bool = true,
            alert: AlertState<Chat.Action>? = nil,
            conversation: ConversationOutPut,
            messages: IdentifiedArrayOf<MessageItem> = [],
            chatButtomState: ChatBottom.State = .init(),
            isCurrentUser: Bool = false,
            currentUser: UserOutput,
            websocketState: WebSocketReducer.State,
            messageItem: MessageItem? = nil
        ) {
            self.isLoadingPage = isLoadingPage
            self.currentPage = currentPage
            self.canLoadMorePages = canLoadMorePages
            self.alert = alert
            self.conversation = conversation
            self.messages = messages
            self.chatButtomState = chatButtomState
            self.isCurrentUser = isCurrentUser
            self.currentUser = currentUser
            self.websocketState = websocketState
            self.messageItem = messageItem

        }

      var isLoadingPage = false
      var currentPage = 1
      var canLoadMorePages = true

      public var alert: AlertState<Action>?
      public var conversation: ConversationOutPut
      public var messages: IdentifiedArrayOf<MessageItem> = []
      public var chatButtomState: ChatBottom.State = .init()
      public var isCurrentUser = false
      public var currentUser: UserOutput
      public var messageItem: MessageItem?
      public var websocketState: WebSocketReducer.State
    }

    public enum Action: Equatable {
      case onAppear
      case alertDismissed
      case fetchMessages
      case messagesResponse(TaskResult<MessagePage>)
      case fetchMoreMessageIfNeeded(currentItem: MessageItem?)
      case fetchMoreMessage(currentItem: MessageItem)
      case message(index: MessageItem.ID, action: ChatRow.Action)
      case webSocketReducer(WebSocketReducer.Action)
      case chatButtom(ChatBottom.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.webSocket) var webSocket
    private enum WebSocketID {}
    
    public init() {}

    public var body: some ReducerProtocol<State, Action> {

        Scope(state: \.websocketState, action: /Action.webSocketReducer) {
            WebSocketReducer()
        }

        Scope(state: \.chatButtomState, action: /Action.chatButtom) {
            ChatBottom()
        }

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        var fetchMoreMessages: Effect<Action, Never> {
            let conversationsID = state.conversation.id.hexString
            let query = QueryItem(page: state.currentPage, per: 10)

            return .task {
                .messagesResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .chatEngine(.conversations(.conversation(id: conversationsID, route: .messages(.list(query: query))))),
                            as: MessagePage.self,
                            decoder: .iso8601
                        )
                    }
                )
            }

        }

        switch action {
        case .onAppear:
            return .run { send in
                await send(.fetchMessages)
            }
        case .fetchMessages:
            return fetchMoreMessages

        case .alertDismissed:
          state.alert = nil
          return .none

        case let .messagesResponse(.success(response)):

          state.isLoadingPage = false

            response.items.forEach {
                if state.messages[id: $0.id] != $0 {
                    state.messages.append($0)
                } else if state.messages.isEmpty {
                    state.messages.append(contentsOf: response.items)
                }
            }

            _ = state.messages
                .sorted(by: { $0.createdAt?.compare($1.createdAt ?? Date()) == .orderedDescending })

            state.canLoadMorePages = state.messages.count < response.metadata.total
            if state.canLoadMorePages {
              state.currentPage += 1
            }

          return .none

        case let .messagesResponse(.failure(error)):
          state.alert = .init(title: TextState("\(error.localizedDescription)"))
          return .none

        case let .fetchMoreMessageIfNeeded(currentItem: currentItem):
          guard let item = currentItem, state.messages.count > 5 else {
            return fetchMoreMessages
          }

          let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -5) - 3
          if state.messages.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
            return fetchMoreMessages
          }
          return .none

        case let .fetchMoreMessage(currentItem: item):

          let threshouldIndex = state.messages.index(state.messages.endIndex, offsetBy: -7)
          if state.messages.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
            return fetchMoreMessages
          }

            let localMessage = MessageItem(
              id: ObjectId(),
              conversationId: state.conversation.id,
              messageBody: state.chatButtomState.composedMessage,
              messageType: .text,
              isRead: false,
              isDelivered: false,
              sender: state.currentUser,
              recipient: nil,
              createdAt: nil, updatedAt: nil, deletedAt: nil
            )

          state.messages.insert(localMessage, at: 0)

            return .none

        case .webSocketReducer:
            return .none

        case .chatButtom(let cb):
            switch cb {

            case .sendButtonTapped:

                let conversationsID = state.conversation.id
                let currentDate = Date()
                let localMessage = MessageItem(
                  id: ObjectId(),
                  conversationId: conversationsID,
                  messageBody: state.chatButtomState.messageToSend,
                  messageType: .text,
                  isRead: false,
                  isDelivered: false,
                  sender: state.currentUser,
                  recipient: nil,
                  createdAt: currentDate, updatedAt: currentDate,
                  deletedAt: nil
                )

                state.messages.insert(localMessage, at: 0)
                state.messageItem = localMessage
                
                state.chatButtomState.messageToSend = ""

                guard let sendServerMsgJsonString = ChatOutGoingEvent.message(localMessage).jsonString else {
                  print(#line, "json String convert issue")
                  return .none
                }
                
                return .run { send in
                    await send(.webSocketReducer(.messageToSendChanged(sendServerMsgJsonString)))
                }

            case .messageToSendChanged:
                return .none
            }
        }
    }
}
