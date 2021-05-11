//
//  TabsReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import ComposableCoreLocation

import EventView
import ConversationView
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


public let tabsReducer = Reducer<TabsState, TabsAction, Void>.combine(
  eventReducer.pullback(
    state: \.event,
    action: /TabsAction.event,
    environment: {
      EventsEnvironment(
        pathMonitorClient: PathMonitorClient.live(queue: .main),
        locationManager: LocationManager.live,
        eventClient: EventClient.live(api: .build),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    }
  ),
  conversationReducer.pullback(
    state: \.conversations,
    action: /TabsAction.conversation,
    environment: {
      ConversationEnvironment(
        conversationClient: ConversationClient.live(api: .build),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
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
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    }
  ),
  
  Reducer { state, action, environment in
    switch action {
    
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
      
    }
  }
)
