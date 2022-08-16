//
//  TabAction.swift
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
import SwiftUI
import AddaSharedModels
import AppDelegate

public enum TabAction: Equatable {
    case onAppear
    case didSelectTab(TabState.Tab)
    case event(EventsAction)
    case conversation(ConversationsAction)
    case profile(ProfileAction)

    case webSocket(WebSocketClient.Action)
    case getAccessToketFromKeyChain(Result<String, HTTPRequest.HRError>)
    case receivedSocketMessage(Result<WebSocketClient.Message, NSError>)
    case deviceResponse(Result<DeviceInOutPut, HTTPRequest.HRError>)
    case sendResponse(NSError?)
    case tabViewIsHidden(Bool)
    case scenePhase(ScenePhase)
}

extension TabAction {
  init(_ action: TabsView.ViewAction) {
    switch action {
    case .onAppear:
      self = .onAppear
    case let .didSelectTab(tab):
      self = .didSelectTab(tab)
    case let .tabViewIsHidden(value):
      self = .tabViewIsHidden(value)
    }
  }
}
