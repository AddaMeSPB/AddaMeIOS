//
//  TabsState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import EventView
import ChatView
import ProfileView

public struct TabsState: Equatable {
  
  public init(
    selectedTab: Tabs,
    event: EventsState,
    chat: ChatState,
    profile: ProfileState
  ) {
    self.selectedTab = selectedTab
    self.event = event
    self.chat = chat
    self.profile = profile
  }
  
  public var selectedTab: Tabs
  public var event: EventsState
  public var chat: ChatState
  public var profile: ProfileState
  
}

struct TabsViewState: Equatable {
  init(state: TabsState) {
    selectedTab = state.selectedTab
  }
  
  var selectedTab: Tabs
}
