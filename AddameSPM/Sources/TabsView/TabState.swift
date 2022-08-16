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

public struct TabState: Equatable {

    public var selectedTab: Tab = .event
    public var event: EventsState
    public var conversations: ConversationsState
    public var profile: ProfileState
    public var isHidden = false
    public var accessToken = ""
    public var appDelegate: AppDelegateState
    public var unreadMessageCount: Int

    public enum Tab: Equatable {
      case event
      case conversation
      case profile
    }

    public init(
        selectedTab: TabState.Tab = .event,
        event: EventsState,
        conversations: ConversationsState,
        profile: ProfileState,
        isHidden: Bool = false,
        accessToken: String = "",
        appDelegate: AppDelegateState,
        unreadMessageCount: Int
    ) {
        self.selectedTab = selectedTab
        self.event = event
        self.conversations = conversations
        self.profile = profile
        self.isHidden = isHidden
        self.accessToken = accessToken
        self.appDelegate = appDelegate
        self.unreadMessageCount = unreadMessageCount
    }
}
