//
//  TabsReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import UIKit
import Foundation
import ComposableArchitecture
import ComposableCoreLocation
import ConversationsView
import EventView
import InfoPlist
import KeychainClient
import ProfileView
import AddaSharedModels
import DeviceClient
import NotificationHelpers
import BSON
import WebSocketReducer

public struct TabReducer: ReducerProtocol {
    public struct State: Equatable {
        public var hangouts: Hangouts.State
        public var conversations: Conversations.State
        public var profile: Profile.State
        public var isHidden = false
        public var unreadMessageCount: Int = 0
        public var currentUser: UserOutput = .withFirstName // have to not optional
        public var websocketState: WebSocketReducer.State

        public var selectedTab: Tab = .hangouts
        public enum Tab: Equatable { case hangouts, conversations, profile }

        public init(
            selectedTab: TabReducer.State.Tab = .hangouts,
            hangouts: Hangouts.State = .init(websocketState: .init(user: .withFirstName)),
            conversations: Conversations.State = .init(websocketState: .init(user: .withFirstName)),
            profile: Profile.State = .init(),
            isHidden: Bool = false,
            websocketState: WebSocketReducer.State = .init(user: .withFirstName)
        ) {
            self.selectedTab = selectedTab
            self.hangouts = hangouts
            self.conversations = conversations
            self.profile = profile
            self.isHidden = isHidden
            self.websocketState = websocketState
        }
    }

    public enum Action: Equatable {
        case onAppear
        case didSelectTab(State.Tab)
        case hangouts(Hangouts.Action)
        case conversations(Conversations.Action)
        case profile(Profile.Action)
        case tabViewIsHidden(Bool)
        case webSocketReducer(WebSocketReducer.Action)
//        case scenePhase(ScenePhase)
    }

    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some ReducerProtocol<State, Action> {

        Scope(state: \.websocketState, action: /Action.webSocketReducer) {
            WebSocketReducer()
        }

        Scope(state: \.hangouts, action: /Action.hangouts) {
            Hangouts()
        }

        Scope(state: \.conversations, action: /Action.conversations) {
            Conversations()
        }

        Scope(state: \.profile, action: /Action.profile) {
            Profile()
        }

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {

        func handle(_ data: Data) {
                let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)

                switch chatOutGoingEvent {
                case .connect(_):
                    break
                case .disconnect(_):
                    break
                case .conversation(let lastMessage):

                    guard var findConversation = state.conversations.conversations[id: lastMessage.conversationId]
                    else { return  }

                    guard let index = state.conversations.conversations.firstIndex(where: { $0.id == findConversation.id })
                    else { return }

                    findConversation.lastMessage = lastMessage
                    state.conversations.conversations[id: lastMessage.conversationId] = findConversation
                    state.conversations.conversations.swapAt(index, 0)

                case .message(let message):
                    print(#line, message)
                    state.conversations.chatState?.messages.insert(message, at: 0)

                case .notice(let msg):
                    print(#line, msg)
                case .error(let error):
                    print(#line, error)
                case .none:
                    print(#line, "decode error")
                }
            }

        switch action {

        case .onAppear:
            do {
                state.currentUser = try self.keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
            } catch {
                //state.alert = .init(title: TextState("Missing you id! please login again!"))
                return .none
            }

            state.websocketState.user = state.currentUser

            return .run { send in
              await send(.webSocketReducer(.connectButtonTapped))
            }

        case .didSelectTab(let tab):
            state.selectedTab = tab
            return .none
        case .tabViewIsHidden(_):
            return .none

        case let .hangouts(.hangoutFormView(isNavigate: active)):
            state.isHidden = active
            
//            UITabBar.appearance().isHidden = active
            return .none
        case .hangouts:
            state.hangouts.websocketState = state.websocketState
            return .none
        case .conversations:
            state.conversations.websocketState = state.websocketState
            return .none
        case .profile:
            return .none

        case .webSocketReducer(.receivedSocketMessage(.success(let responseString))):

            switch responseString {

            case .data:
                return .none
                
            case .string(let resString):
                guard let data = resString.data(using: .utf8) else {
                    return .none
                }
                handle(data)
                return .none
            }

        case .webSocketReducer(.webSocket(.didOpen)):
            let onconnect = ChatOutGoingEvent.connect(state.currentUser).jsonString
            state.websocketState.messageToSend = onconnect!
            return .none
        case .webSocketReducer:
            return .none
        }
    }
}

// public let tabsReducer = Reducer<
//  TabState,
//  TabAction,
//  TabsEnvironment
// >.combine(
//  eventsReducer.pullback(
//    state: \.event,
//    action: /TabAction.event,
//    environment: { _ in EventsEnvironment.live }
//  ),
//  conversationsReducer.pullback(
//    state: \.conversations,
//    action: /TabAction.conversation,
//    environment: { _ in ConversationEnvironment.live }
//  ),
//  profileReducer.pullback(
//    state: \.profile,
//    action: /TabAction.profile,
//    environment: { _ in ProfileEnvironment.live }
//  ),
//
//  Reducer { state, action, environment in
//
//    var getAcceccToken: Effect<TabAction, Never> {
//      return environment.getAccessToken()
//        .receive(on: environment.mainQueue)
//        .catchToEffect()
//        .map(TabAction.getAccessToketFromKeyChain)
//    }
//
//    var receiveSocketMessageEffect: Effect<TabAction, Never> {
//        return environment.webSocketClient.receive(environment.currentUser.id!.hexString)
//        .subscribe(on: environment.backgroundQueue)
//        .receive(on: environment.mainQueue)
//        .catchToEffect()
//        .map(TabAction.receivedSocketMessage)
//        .cancellable(id: environment.currentUser.id)
//    }
//
//    switch action {
//    case let .scenePhase(phase):
//      switch phase {
//      case .background: debugPrint(#line, "background")
//        return .none
//      case .inactive: debugPrint(#line, "inactive")
//        return .none
//      case .active: debugPrint(#line, "active")
//          return getAcceccToken
//      @unknown default:
//        debugPrint(#line, "default")
//        return .none
//      }
//    case .onAppear:
//        return getAcceccToken
//
//    case let .didSelectTab(tab):
//      state.selectedTab = tab
//      return .none
//
//    case .event: return .none
//    case .conversation: return .none
//    case .profile: return .none
//
//    case let .tabViewIsHidden(value):
////      let tab = state.selectedTab
////      if value == true {
////        state.isHidden = true
////      } else if (tab == .event || tab == .conversation || tab == .profile) == true {
////        state.isHidden = false
////      }
//
//      return .none
//
//    case let .getAccessToketFromKeyChain(.success(accessToken)):
//
//      guard let onconnect = ChatOutGoingEvent
//        .connect(environment.currentUser)
//        .jsonString else {
//        // alert :)
//        return .none
//      }
//
//        guard let id = environment.currentUser.id else {
//           debugPrint("currentUserMissing")
//           return .none
//        }
//
//      state.accessToken = accessToken
//      accessTokenTemp = accessToken
//      var baseURL: URL { EnvironmentKeys.webSocketURL }
//
//      return .merge(
//        environment.webSocketClient.open(id.hexString, baseURL, accessToken, [])
//          .subscribe(on: environment.backgroundQueue)
//          .receive(on: environment.mainQueue)
//          .map(TabAction.webSocket)
//          .eraseToEffect()
//          .cancellable(id: environment.currentUser.id),
//
//        environment.webSocketClient.send(environment.currentUser.id!.hexString, .string(onconnect))
//          .subscribe(on: environment.backgroundQueue)
//          .receive(on: environment.mainQueue)
//          .eraseToEffect()
//          .map(TabAction.sendResponse)
//      )
//
//    case let .getAccessToketFromKeyChain(.failure(error)):
//      return .none
//
//    case let .sendResponse(error):
//      print(#line, error as Any)
//      return .none
//
//    case .webSocket(.didOpenWithProtocol):
//      return receiveSocketMessageEffect
//
//    case let .receivedSocketMessage(.success(.data(data))):
//      return receiveSocketMessageEffect
//    case .webSocket(.didBecomeInvalidWithError(_)):
//      return .none
//    case let .webSocket(.didClose(code: code, reason: reason)):
//      return .none
//    case .webSocket(.didCompleteWithError(_)):
//      return .none
//    case .receivedSocketMessage(.failure(_)):
//      return .none
//    case let .receivedSocketMessage(.success(.string(str))):
//
//      guard let data = str.data(using: .utf8) else {
//        return receiveSocketMessageEffect
//      }
//
//      let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)
//
//      switch chatOutGoingEvent {
//      case .connect:
//        return receiveSocketMessageEffect
//      case .disconnect:
//        return receiveSocketMessageEffect
//      case let .conversation(messageResponse):
//          print(#line, messageResponse.conversationId)
//          return
//              .merge(
//                .task { .conversation(.updateLastConversation(messageResponse)) },
//                receiveSocketMessageEffect
//              )
//
////        return  receiveSocketMessageEffect
//
//      case let .message(message):
//        guard
//          let chatState = state.conversations.chatState,
//          let conversation = chatState.conversation
//        else {
//          return receiveSocketMessageEffect
//        }  // wrong
//
//        if conversation.id == message.conversationId {
//          state.conversations.chatState?.messages.insert(message, at: 0)
//        }
//
//        return receiveSocketMessageEffect
//
//      case let .notice(msg):
//        return receiveSocketMessageEffect
//      case let .error(error):
//        print(#line, error)
//        return receiveSocketMessageEffect
//      case .none:
//        print(#line, "decode error")
//        return receiveSocketMessageEffect
//      }
//    case let .deviceResponse(.success(response)):
//        print("deviceResponse", response)
//        return .none
//    case let .deviceResponse(.failure(error)):
//        print("deviceErro", error)
//        return .none
//    }
//  }
// )
// .debug()
