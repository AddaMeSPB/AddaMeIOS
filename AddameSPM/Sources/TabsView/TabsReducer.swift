//
//  TabsReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import ComposableCoreLocation
import ConversationsView
import EventView
import InfoPlist
import KeychainService
import ProfileView
import SharedModels

public let tabsReducer = Reducer<
  TabsViewState,
  TabsAction,
  TabsEnvironment
>.combine(
  eventsReducer.pullback(
    state: \.event,
    action: /TabsAction.event,
    environment: { _ in EventsEnvironment.live }
  ),
  conversationsReducer.pullback(
    state: \.conversations,
    action: /TabsAction.conversation,
    environment: { _ in ConversationEnvironment.live }
  ),
  profileReducer.pullback(
    state: \.profile,
    action: /TabsAction.profile,
    environment: { _ in ProfileEnvironment.live }
  ),

  Reducer { state, action, environment in

    var getAcceccToken: Effect<TabsAction, Never> {
      return environment.getAccessToken()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TabsAction.getAccessToketFromKeyChain)
    }

    var receiveSocketMessageEffect: Effect<TabsAction, Never> {
      return environment.webSocketClient.receive(environment.currentUser.id)
        .subscribe(on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TabsAction.receivedSocketMessage)
        .cancellable(id: environment.currentUser.id)
    }

    switch action {
    case .onAppear:
      return getAcceccToken

    case let .didSelectTab(tab):
      state.selectedTab = tab

      return .none

    case .event:
      return .none

    case .conversation:
      return .none

    case .profile:

      return .none
    case let .tabViewIsHidden(value):
//      let tab = state.selectedTab
//      if value == true {
//        state.isHidden = true
//      } else if (tab == .event || tab == .conversation || tab == .profile) == true {
//        state.isHidden = false
//      }

      return .none

    case let .getAccessToketFromKeyChain(.success(accessToken)):

      guard let onconnect = ChatOutGoingEvent.connect(environment.currentUser).jsonString else {
        // alert :)
        return .none
      }

      var baseURL: URL { EnvironmentKeys.webSocketURL }

      return .merge(
        environment.webSocketClient.open(environment.currentUser.id, baseURL, accessToken, [])
          .subscribe(on: environment.backgroundQueue)
          .receive(on: environment.mainQueue)
          .map(TabsAction.webSocket)
          .eraseToEffect()
          .cancellable(id: environment.currentUser.id),

        environment.webSocketClient.send(environment.currentUser.id, .string(onconnect))
          .subscribe(on: environment.backgroundQueue)
          .receive(on: environment.mainQueue)
          .eraseToEffect()
          .map(TabsAction.sendResponse)
      )

    case let .getAccessToketFromKeyChain(.failure(error)):
      return .none

    case let .sendResponse(error):
      print(#line, error as Any)
      return .none

    case .webSocket(.didOpenWithProtocol):
      return receiveSocketMessageEffect

    case let .receivedSocketMessage(.success(.data(data))):
      return receiveSocketMessageEffect
    case .webSocket(.didBecomeInvalidWithError(_)):
      return .none
    case let .webSocket(.didClose(code: code, reason: reason)):
      return .none
    case .webSocket(.didCompleteWithError(_)):
      return .none
    case .receivedSocketMessage(.failure(_)):
      return .none
    case let .receivedSocketMessage(.success(.string(str))):

      guard let data = str.data(using: .utf8) else {
        return receiveSocketMessageEffect
      }

      let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)

      switch chatOutGoingEvent {
      case .connect:
        return receiveSocketMessageEffect
      case .disconnect:
        return receiveSocketMessageEffect
      case let .conversation(message):

        state.conversations.conversations[id: message.conversationId]?
          .lastMessage = message

        state.conversations.conversations.sort()

        return receiveSocketMessageEffect

      case let .message(message):
        guard
          let chatState = state.conversations.chatState,
          let conversation = chatState.conversation
        else {
          return receiveSocketMessageEffect
        }  // wrong

        if conversation.id == message.conversationId {
          state.conversations.chatState?.messages.insert(message, at: 0)
        }

        return receiveSocketMessageEffect

      case let .notice(msg):
        return receiveSocketMessageEffect
      case let .error(error):
        print(#line, error)
        return receiveSocketMessageEffect
      case .none:
        print(#line, "decode error")
        return receiveSocketMessageEffect
      }
    }
  }
)
.debug()
