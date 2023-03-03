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
import SettingsFeature
import ProfileView
import InfoPlist
import KeychainClient
import AddaSharedModels
import DeviceClient
import NotificationHelpers
import BSON
import WebSocketReducer
import os

public struct TabReducer: ReducerProtocol {

    public struct State: Equatable {
        public var hangouts: Hangouts.State
        public var conversations: Conversations.State
        public var profile: Profile.State
        public var settings: Settings.State
        public var isHidden = false
        public var unreadMessageCount: Int = 0
        public var currentUser: UserOutput = .withFirstName // have to not optional
        public var websocketState: WebSocketReducer.State

        public var selectedTab: Tab = .hangouts
        public enum Tab: Equatable { case hangouts, conversations, profile, settings }

        public init(
            selectedTab: TabReducer.State.Tab = .hangouts,
            hangouts: Hangouts.State = .init(websocketState: .init(user: .withFirstName)),
            conversations: Conversations.State = .init(websocketState: .init(user: .withFirstName)),
            profile: Profile.State = .init(),
            settings: Settings.State = .init(),
            isHidden: Bool = false,
            websocketState: WebSocketReducer.State = .init(user: .withFirstName)
        ) {
            self.selectedTab = selectedTab
            self.hangouts = hangouts
            self.conversations = conversations
            self.profile = profile
            self.settings = settings
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
        case settings(Settings.Action)
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

        Scope(state: \.settings, action: /Action.settings) {
          Settings()
        }

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {

        func handle(_ data: Data) {
                let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)

                switch chatOutGoingEvent {
                case .connect(_):
                    break
                case .disconnect:
                    let warning = state.websocketState.user.id
                    logger.warning("websocker disconnect for user \(warning)")
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
        case .settings:
            return .none
        }
    }
}


public let logger = Logger(subsystem: "com.addame.AddaMeIOS", category: "tabs.reducer")
