//
//  TabsAction.swift
//
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import EventView
import ConversationsView
import ProfileView
import Foundation
import HTTPRequestKit
import WebSocketClient

public enum TabsAction: Equatable {
  case onAppear
  case didSelectTab(Tab)
  case event(EventsAction)
  case conversation(ConversationsAction)
  case profile(ProfileAction)

  case webSocket(WebSocketClient.Action)
  case getAccessToketFromKeyChain(Result<String, HTTPRequest.HRError>)
  case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
  case sendResponse(NSError?)
  case tabViewIsHidden(Bool)
}

extension TabsAction {
  static func view(_ localAction: TabsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case let .didSelectTab(tab):
      return .didSelectTab(tab)
    case let .event(action):
      return .event(action)
    case let .conversation(action):
      return .conversation(action)
    case let .profile(action):
      return .profile(action)
    case let .tabViewIsHidden(value):
      return .tabViewIsHidden(value)
    }
  }
}
