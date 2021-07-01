//
//  TabsReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import ComposableCoreLocation

import EventView
import ConversationsView
import ProfileView

import UserClient
import UserClientLive

import AuthClient
import AuthClientLive

import EventClient
import EventClientLive

import AttachmentClient
import AttachmentClientLive

import PathMonitorClient
import PathMonitorClientLive

import ConversationClient
import ConversationClientLive

import InfoPlist
import SharedModels
import KeychainService

public let tabsReducer = Reducer<TabsState, TabsAction, TabsEnvironment>.combine(
  eventReducer.pullback(
    state: \.event,
    action: /TabsAction.event,
    environment: {
      EventsEnvironment(
        pathMonitorClient: PathMonitorClient.live(queue: .main),
        locationManager: LocationManager.live,
        eventClient: EventClient.live(api: .build),
        backgroundQueue: $0.backgroundQueue,
        mainQueue: $0.mainQueue
      )
    }
  ),
  conversationsReducer.pullback(
    state: \.conversations,
    action: /TabsAction.conversation,
    environment: {
      ConversationEnvironment(
        conversationClient: ConversationClient.live(api: .build),
        websocketClient: .live,
        backgroundQueue: $0.backgroundQueue,
        mainQueue: $0.mainQueue
      )
    }
  ),
  profileReducer.pullback(
    state: \.profile,
    action: /TabsAction.profile,
    environment: {
      ProfileEnvironment(
        userClient: UserClient.live(api: .build),
        eventClient: EventClient.live(api: .build),
        authClient: AuthClient.live(api: .build),
        attachmentClient: AttachmentClient.live(api: .build),
        backgroundQueue: $0.backgroundQueue,
        mainQueue: $0.mainQueue
      )
    }
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

      state.profile.myEvents = state.event.myEvents

      return .none

    case .getAccessToketFromKeyChain(.success(let accessToken)):

      let onconnect = ChatOutGoingEvent.connect(environment.currentUser).jsonString

      var baseURL: URL { EnvironmentKeys.webSocketURL }

      return .merge(
        environment.webSocketClient.open(environment.currentUser.id, baseURL, accessToken, [])
          .subscribe(on: environment.backgroundQueue)
          .receive(on: environment.mainQueue)
          .map(TabsAction.webSocket)
          .eraseToEffect()
          .cancellable(id: environment.currentUser.id),

        environment.webSocketClient.send(environment.currentUser.id, .string(onconnect!))
          .subscribe(on: environment.backgroundQueue)
         .receive(on: environment.mainQueue)
         .eraseToEffect()
         .map(TabsAction.sendResponse)
      )

    case .getAccessToketFromKeyChain(.failure(let error)):
      return .none

    case .sendResponse(let error):
      print(#line, error as Any)
      return .none

    case .webSocket(.didOpenWithProtocol):
      return receiveSocketMessageEffect

    case .receivedSocketMessage(.success(.data(let data))):
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
        return .none
      }

      let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)

      switch chatOutGoingEvent {
      case .connect(_):
        break
      case .disconnect(_):
        break
      case .conversation(let message):

        if let row = state.conversations.conversations.firstIndex(where: { $0.id == message.conversationId }) {
          state.conversations.conversations[row].lastMessage = message
        }

      case .message(let message):
        state.conversations.chatState?.messages.insert(message, at: 0)

      case .notice(let msg):
        break
      case .error(let error):
        print(#line, error)
      case .none:
        print(#line, "decode error")
        return receiveSocketMessageEffect
      }

      return receiveSocketMessageEffect
    }
  }
)
