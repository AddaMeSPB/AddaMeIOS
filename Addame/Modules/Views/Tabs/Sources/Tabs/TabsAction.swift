//
//  TabsAction.swift
//  
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import EventView
import ChatView
import ProfileView

public enum TabsAction: Equatable {
  case didSelectTab(Tabs)
  case event(EventsAction)
  case chat(ChatAction)
  case profile(ProfileAction)
}
