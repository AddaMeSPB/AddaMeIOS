//
//  TabsState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import EventView
import ConversationsView
import ProfileView

public struct TabsState: Equatable {
  
  public init(
    selectedTab: Tabs,
    event: EventsState,
    conversations: ConversationsState,
    profile: ProfileState
  ) {
    self.selectedTab = selectedTab
    self.event = event
    self.conversations = conversations
    self.profile = profile
  }
  
  public var selectedTab: Tabs
  public var event: EventsState
  public var conversations: ConversationsState
  public var profile: ProfileState
  
}

struct TabsViewState: Equatable {
  init(state: TabsState) {
    selectedTab = state.selectedTab
  }
  
  var selectedTab: Tabs
}
