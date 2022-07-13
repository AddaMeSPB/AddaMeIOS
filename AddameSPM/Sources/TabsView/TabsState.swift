//
//  TabsState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ConversationsView
import EventView
import ProfileView
import AppDelegate

public enum Tab: Equatable {
  case event
  case conversation
  case profile
}

extension TabsViewState {
    public static var live: TabsViewState = .init(
          selectedTab: .event,
          event: EventsState(),
          conversations: ConversationsState(),
          profile: ProfileState(),
          appDelegate: AppDelegateState()
        )
}

public struct TabsViewState: Equatable {
    public var selectedTab: Tab = .event
    public var event: EventsState
    public var conversations: ConversationsState
    public var profile: ProfileState
    public var isHidden = false
    public var accessToken = ""
    public var appDelegate: AppDelegateState = .init()

  public init(
    selectedTab: Tab = .event,
    event: EventsState = .init(),
    conversations: ConversationsState = .init(),
    profile: ProfileState = .init(),
    appDelegate: AppDelegateState = .init()
  ) {
    self.selectedTab = selectedTab
    self.event = event
    self.conversations = conversations
    self.profile = profile
    self.appDelegate = appDelegate
  }

}

extension TabsViewState {
  public var view: TabsView.ViewState {
    TabsView.ViewState(
      selectedTab: selectedTab,
      event: event,
      conversations: conversations,
      profile: profile,
      isHidden: isHidden,
      accessToken: accessToken,
      appDelegate: appDelegate
    )
  }
}
