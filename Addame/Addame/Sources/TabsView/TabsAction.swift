//
//  TabsAction.swift
//  
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import EventView
import ConversationsView
import ProfileView

public enum TabsAction: Equatable {
  case didSelectTab(Tabs)
  case event(EventsAction)
  case conversation(ConversationsAction)
  case profile(ProfileAction)
}
