//
//  TabsState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ConversationsView
import EventView
import ProfileView

public enum Tab: Equatable {
  case event
  case conversation
  case profile
}

public struct TabsViewState: Equatable {
  public init(
    selectedTab: Tab,
    event: EventsState,
    conversations: ConversationsState,
    profile: ProfileState
  ) {
    self.selectedTab = selectedTab
    self.event = event
    self.conversations = conversations
    self.profile = profile
  }

  public var selectedTab: Tab = .event
  public var event: EventsState
  public var conversations: ConversationsState
  public var profile: ProfileState
  public var isHidden = false
}

extension TabsViewState {
  public var view: TabsView.ViewState {
    TabsView.ViewState(
      selectedTab: selectedTab,
      event: event,
      conversations: conversations,
      profile: profile,
      isHidden: isHidden
    )
  }
}
