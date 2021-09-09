//
//  TabsAction.swift
//
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import ConversationsView
import EventView
import Foundation
import HttpRequest
import ProfileView
import WebSocketClient

public enum TabsAction: Equatable {
  case onAppear
  case didSelectTab(Tabs)
  case event(EventsAction)
  case conversation(ConversationsAction)
  case profile(ProfileAction)

  case webSocket(WebSocketClient.Action)
  case getAccessToketFromKeyChain(Result<String, HTTPError>)
  case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
  case sendResponse(NSError?)
}
