//
//  TabsView.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import EventView
import ConversationsView
import ProfileView
import SwiftUI

public struct TabsView: View {

  @AppStorage("isUserFirstNameEmpty")
  public var isUserFirstNameEmpty: Bool = true
  @Environment(\.colorScheme) var colorScheme

  struct ViewState: Equatable {
    public init(state: TabsState) {
      self.selectedTab = state.selectedTab
      self.event = state.event
      self.conversations = state.conversations
      self.profile = state.profile
    }

    public var selectedTab: Tabs
    public var event: EventsState
    public var conversations: ConversationsState
    public var profile: ProfileState
  }

  let store: Store<TabsState, TabsAction>

  public init(store: Store<TabsState, TabsAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store.scope(state: ViewState.init)) { viewStore in
      TabView(selection: viewStore.binding(
        get: \.selectedTab,
        send: TabsAction.didSelectTab
      )) {
        ForEach(
          Tabs.allCases, content: tabView(_:)
        )
      }
      .onAppear {
        ViewStore(store.stateless).send(.onAppear)
      }
    }
  }

  private func tabView(_ tabs: Tabs) -> some View {
    view(for: tabs)
      .tabItem {
        Image(systemName: image(for: tabs))
        Text(title(for: tabs))
      }
      .tag(tabs)
  }

  private func title(for tab: Tabs) -> String {
    switch tab {
    case .event: return "Events"
    case .conversation: return "Chat"
    case .profile: return "Profile"
    }
  }

  private func image(for tab: Tabs) -> String {
    switch tab {
    case .event: return "list.bullet.below.rectangle"
    case .conversation: return "bubble.left.and.bubble.right"
    case .profile: return "person"
    }
  }

  @ViewBuilder
  private func view(for tabs: Tabs) -> some View {
    switch tabs {
    case .event:
      NavigationView {
        EventView(store: store.scope(
          state: \.event,
          action: TabsAction.event
        ))
      }
      .onAppear {
        ViewStore(store.stateless).send(.event(.onAppear))
      }
      .navigationViewStyle(StackNavigationViewStyle())

    case .conversation:
      NavigationView {
        ConversationsView(store: store.scope(
          state: \.conversations,
          action: TabsAction.conversation
        ))
      }
      .onAppear {
        ViewStore(store.stateless).send(.conversation(.onAppear))
      }
      .navigationViewStyle(StackNavigationViewStyle())

    case .profile:

      NavigationView {
        ProfileView(store: store.scope(
          state: \.profile,
          action: TabsAction.profile
        ))
      }
      .onAppear {
        ViewStore(store.stateless).send(.profile(.fetchMyData))
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

struct TabsView_Previews: PreviewProvider {

  static let tabsEnv = TabsEnvironment(
    backgroundQueue: .immediate,
    mainQueue: .immediate,
    webSocketClient: .live
  )

  static let tabsState = TabsState(
    selectedTab: .event,
    event: EventsState.placeholderEvents,
    conversations: ConversationsState.placholderConversations,
    profile: ProfileState()
  )

  static let store = Store(
    initialState: tabsState,
    reducer: tabsReducer,
    environment: tabsEnv
  )

  static var previews: some View {
    TabsView(store: store)
  }
}
