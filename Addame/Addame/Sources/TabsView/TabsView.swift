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

  public init(store: Store<TabsState, TabsAction>) {
    self.store = store
  }

  let store: Store<TabsState, TabsAction>

  public var body: some View {
    WithViewStore(store.scope(state: TabsViewState.init(state:))) { viewStore in
      TabView(selection: viewStore.binding(
        get: \.selectedTab,
        send: TabsAction.didSelectTab
      )) {
        ForEach(Tabs.allCases, content: tabView(_:))
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

//        .sheet(
//          isPresented: $isUserFirstNameEmpty
//        ) {
//          EmptyView()
//        }
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
      .navigationViewStyle(StackNavigationViewStyle())

    case .profile:

      NavigationView {
        ProfileView(store: store.scope(
          state: \.profile,
          action: TabsAction.profile
        ))
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

struct TabsView_Previews: PreviewProvider {

  static let tabsEnv = TabsEnvironment(
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

  static let tabsState = TabsState(
    selectedTab: .event,
    event: EventsState(),
    conversations: ConversationsState(chatState: .init()),
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
