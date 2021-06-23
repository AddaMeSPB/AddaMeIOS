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
      return environment.webSocketClient.receive(WebSocketId())
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(TabsAction.receivedSocketMessage)
        .cancellable(id: WebSocketId())
    }

    struct WebSocketId: Hashable {}

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

      guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
        return .none
      }

      let onconnect = ChatOutGoingEvent.connect(currentUSER).jsonString

      var baseURL: URL { EnvironmentKeys.webSocketURL }

      return .merge(
        environment.webSocketClient.open(WebSocketId(), baseURL, accessToken, [])
          .receive(on: environment.mainQueue)
          .map(TabsAction.webSocket)
          .eraseToEffect()
          .cancellable(id: WebSocketId()),

        environment.webSocketClient.send(WebSocketId(), .string(onconnect!))
         .receive(on: environment.mainQueue)
         .eraseToEffect()
         .map(TabsAction.sendResponse)
      )

    case .getAccessToketFromKeyChain(.failure(let error)):
      return .none

    case .sendResponse(let error):
      print(#line, error)
      return .none

    case .webSocket(_):
      return .none

    case .webSocket(.didOpenWithProtocol):
      return .none

    case .receivedSocketMessage(_):
      return .none
    }
  }
)
