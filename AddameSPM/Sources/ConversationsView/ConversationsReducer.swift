//
//  ConversationReducer.swift
//
//
//  Created by Saroar Khandoker on 20.04.2021.
//

import ChatView
import Combine
import ComposableArchitecture

import ComposableArchitectureHelpers
import ContactsView
import AddaSharedModels
import SwiftUI
import BSON
import Dependencies
import UserDefaultsClient
import KeychainClient
import APIClient
import WebSocketReducer

public struct Conversations: ReducerProtocol {
    public struct State: Equatable {
        public init(
            isLoadingPage: Bool = false,
            canLoadMorePages: Bool = true,
            currentPage: Int = 1,
            alert: AlertState<Action>? = nil,
            conversations: IdentifiedArrayOf<Conversation.State> = [],
            conversation: ConversationOutPut? = nil,
            chatState: Chat.State? = nil,
            contactsState: ContactsReducer.State? = nil,
            createConversation: ConversationCreate? = nil,
            websocketState: WebSocketReducer.State
        ) {
            self.isLoadingPage = isLoadingPage
            self.canLoadMorePages = canLoadMorePages
            self.currentPage = currentPage
            self.alert = alert
            self.conversations = conversations
            self.conversation = conversation
            self.chatState = chatState
            self.contactsState = contactsState
            self.createConversation = createConversation
            self.websocketState = websocketState
        }

        public var isLoadingPage = false
        public var canLoadMorePages = true
        public var currentPage = 1

        public var alert: AlertState<Action>?
        public var conversations: IdentifiedArrayOf<Conversation.State> = []
        public var conversation: ConversationOutPut?
        public var createConversation: ConversationCreate?
        public var chatState: Chat.State?
        public var contactsState: ContactsReducer.State?
        public var websocketState: WebSocketReducer.State

        public var isSheetPresented: Bool { contactsState != nil }
    }

    public enum Action: Equatable {
        case onAppear
        case onDisAppear
        case alertDismissed
        case conversation(id: Conversation.State.ID, action: Conversation.Action)
        case conversationTapped(ConversationOutPut)
        case chatView(isPresented: Bool)
        case contactsView(isPresented: Bool)
        case chat(Chat.Action)
        case contacts(ContactsReducer.Action)

        case fetchConversations
        case conversationsResponse(TaskResult<ConversationsResponse>)
        case updateLastConversation(MessageItem)

        case getConversation
        case conversationResponse(TaskResult<ConversationOutPut>)
        case fetchMoreConversationIfNeeded(currentItem: ConversationOutPut?)
        case webSocketReducer(WebSocketReducer.Action)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.build) var build

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {

        Scope(state: \.websocketState, action: /Action.webSocketReducer) {
            WebSocketReducer()
        }

        Reduce(self.core)
            .ifLet(\.chatState, action: /Conversations.Action.chat) {
                Chat()
            }
            .forEach(\.conversations, action: /Action.conversation(id:action:)) {
              Conversation()
            }
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {

        var fetchMoreConversations: Effect<Action, Never> {
            let query = QueryItem(page: state.currentPage, per: 10)

              return .task {
                  await .conversationsResponse(
                    TaskResult {
                        try await apiClient.request(
                            for: .chatEngine(.conversations(.list(query: query))),
                            as: ConversationsResponse.self,
                            decoder: .iso8601
                        )
                    }
                )
              }
        }

        func createOrFine() -> Effect<Action, Never> {

          guard let createConversation = state.createConversation else {
            // fire alert
              state.alert = .init(title: .init("Conversation not created. Please try again!"))
            return .none
          }

            return .task {
                .conversationResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .chatEngine(.conversations(.create(input: createConversation))),
                            as: ConversationOutPut.self,
                            decoder: .iso8601
                        )
                    }
                )
            }
        }

        func presentChatView() -> Effect<Action, Never> {
          state.chatState = nil
          return Effect(value: Action.chatView(isPresented: true))
            .receive(on: mainQueue)
            .eraseToEffect()
        }

        switch action {
        case .onAppear:
          return .run { send in
            await send(.fetchConversations)
          }

        case .onDisAppear:
            state.canLoadMorePages = true
            return .none

        case .fetchConversations:
            state.isLoadingPage = true
            return fetchMoreConversations

        case let .fetchMoreConversationIfNeeded(currentItem):

          guard !state.isLoadingPage, state.canLoadMorePages else {
            return .none
          }

          guard let item = currentItem, state.conversations.count > 7 else {
            return fetchMoreConversations
          }

          let threshouldIndex = state.conversations.index(state.conversations.endIndex, offsetBy: -7)

          if state.conversations.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
            return fetchMoreConversations
          }

          return .none

        case let .chatView(isPresented: present):
            state.chatState = present ? Chat.State.init(
                conversation: state.conversation!,
                currentUser: state.websocketState.user,
                websocketState: state.websocketState
            ) : nil
            
          return .none

        case let .contactsView(isPresented: present):

          state.contactsState = present ? ContactsReducer.State() : nil
          return .none

        case let .conversationsResponse(.success(response)):

            state.isLoadingPage = false

            response.items.forEach {
                if state.conversations[id: $0.id] != $0 {
                    state.conversations.append($0)
                }
            }

            if state.conversations.isEmpty {
                state.conversations.append(contentsOf: response.items)
            }

            let newConversations = state.conversations
                .filter { $0.lastMessage != nil }
                .sorted { $0.lastMessage!.updatedAt! > $1.lastMessage!.updatedAt! }

            state.conversations = .init(uniqueElements: newConversations)

            state.canLoadMorePages = state.conversations.count < response.metadata.total
//            if state.canLoadMorePages {
//                state.currentPage += 1
//            }

          return .none

        case let .conversationsResponse(.failure(error)):
            state.isLoadingPage = false
            state.alert = .init(title: TextState("Error happens \(error.localizedDescription)"))
          return .none

        case let .updateLastConversation(messageResponse):
//            print(#line, messageResponse.conversationId)
//            let updatedIndex = state.conversations.firstIndex(where: { $0.id == messageResponse.id })
//            state.conversations[id: messageResponse.conversationId]?.lastMessage = messageResponse
//
//            state.conversations.sort()
            return .none

        case .alertDismissed:
          state.alert = nil
          return .none

        case let .conversationTapped(conversationItem):
          state.conversation = conversationItem
            // can do some animation on cell until get conversation
            return .run { send in
                await send(.getConversation)
            }

        case .getConversation:
            guard let conversationID = state.conversation?.id.hexString else {
                return .none
            }
            
            return .task {
                await .conversationResponse(
                    TaskResult {
                        try await apiClient.request(
                            for: .chatEngine(.conversations(.conversation(id: conversationID, route: .find))),
                            as: ConversationOutPut.self,
                            decoder: .iso8601
                        )
                    }
                )
            }

        case .chat(.chatButtom(.sendButtonTapped)):

            guard let lastMessage = state.chatState?.messageItem
            else { return .none }

            guard var findConversation = state.conversations[id: lastMessage.conversationId]
            else { return .none }

            guard let index = state.conversations.firstIndex(where: { $0.id == findConversation.id })
            else { return .none }

            findConversation.lastMessage = lastMessage
            state.conversations[id: lastMessage.conversationId] = findConversation
            state.conversations.swapAt(index, 0)

            return .none

        case .chat:
          return .none

        case let .conversationResponse(.success(response)):
          state.contactsState = nil
          state.conversation = response
          print(#line, "conversationResponse", response)
          return presentChatView()

        case let .conversationResponse(.failure(error)):
            print(error)
          return .none

        case let .contacts(.contact(id: id, action: action)):
          switch action {
          case let .moveToChatRoom(bool):
            print(#line, bool)
            return .none
          case let .chatWith(name: name, phoneNumber: phoneNumber):

            state.createConversation = ConversationCreate(
              title: name,
              type: .oneToOne,
              opponentPhoneNumber: phoneNumber
            )

            return createOrFine()
          }

        case .contacts(.contactsAuthorizationStatus(_)):
          return .none
        case .contacts(.contactsResponse(_)):
          return .none
        case .contacts(.moveToChatRoom(_)):
          return .none
        case let .contacts(.chatWith(name: name, phoneNumber: phoneNumber)):
          return .none
        case .contacts(.onAppear):
          return .none
        case .contacts(.alertDismissed):
          return .none
        case .webSocketReducer:
            return .none
        case let .conversation(id, action: action):
            return .none
        }
    }
}


//private func handle(_ data: Data) {
//        let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)
//
//        switch chatOutGoingEvent {
//        case .connect(_):
//            break
//        case .disconnect(_):
//            break
//        case .conversation(let conversation):
//            print(#line, conversation)
//            //self.handleConversationResponse(conversation)
//        case .message(let message):
//            print(#line, message)
//            //self.handleMessageResponse(message)
//        case .notice(let msg):
//            print(#line, msg)
//        case .error(let error):
//            print(#line, error)
//        case .none:
//            print(#line, "decode error")
//        }
//    }

//    private func handleConversationResponse(_ lastMessage: ChatMessageResponse.Item) {
//      DispatchQueue.main.async { [weak self] in
//            withAnimation(.spring()) {
//              guard let self = self else { return }
//                guard var conversationLastMessage = self.conversations[lastMessage.conversationId] else { return }
//
//                conversationLastMessage.lastMessage = lastMessage
//                self.conversations[lastMessage.conversationId] = conversationLastMessage
//            }
//        }
//    }
//
//    private func handleMessageResponse(_ message: ChatMessageResponse.Item) {
//        insert(message)
//    }

// swiftlint:disable:next line_length superfluous_disable_command
// public let conversationsReducer = Reducer<
//  ConversationsState, ConversationsAction, ConversationEnvironment
// > { state, action, environment in
//
//
// }
// .presenting(
//  chatReducer,
//  state: .keyPath(\.chatState),
//  id: .notNil(),
//  action: /ConversationsAction.chat,
//  environment: { _ in ChatEnvironment.live }
// )
// .presenting(
//  contactsReducer,
//  state: .keyPath(\.contactsState),
//  id: .notNil(),
//  action: /ConversationsAction.contacts,
//  environment: { _ in ContactsEnvironment.live }
// )
