//
//  TabsView.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import ConversationsView
import EventView
import ProfileView
import SwiftUI
import SwiftUIExtension

public struct TabsView: View {

  public struct ViewState: Equatable {
    public init(
      selectedTab: Tab,
      event: EventsState,
      conversations: ConversationsState,
      profile: ProfileState,
      isHidden: Bool
    ) {
      self.selectedTab = selectedTab
      self.event = event
      self.conversations = conversations
      self.profile = profile
      self.isHidden = isHidden
    }

    public var selectedTab: Tab
    public var event: EventsState
    public var conversations: ConversationsState
    public var profile: ProfileState
    public var isHidden = false
  }

  public enum ViewAction: Equatable {
    case onAppear
    case didSelectTab(Tab)
    case event(EventsAction)
    case conversation(ConversationsAction)
    case profile(ProfileAction)
    case tabViewIsHidden(Bool)
  }

  let store: Store<TabsViewState, TabsAction>

  public init(store: Store<TabsViewState, TabsAction>) {
    self.store = store
  }

  @State var isHidden = false
  @State var tab: Tab = .event

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: TabsAction.view
      )
    ) { viewStore in

      HidableTabView(
        isHidden: viewStore.binding(get: { $0.isHidden }, send: ViewAction.tabViewIsHidden),
        selection: viewStore.binding(get: { $0.selectedTab }, send: ViewAction.didSelectTab)
      ) {
        NavigationView {
          EventView(
            store: store.scope(state: \.event, action: TabsAction.event)
          )
          .onAppear {
            ViewStore(store.stateless).send(.event(.onAppear))
          }

        }
        .tabItem {
          Image(systemName: "list.bullet.below.rectangle")
          Text("Event")
        }
        .tag(Tab.event)

        NavigationView {
          ConversationsView(
            store: store.scope(state: \.conversations, action: TabsAction.conversation)
          )
          .onAppear {
            self.isHidden = false
            print("### \(self.isHidden) ConversationsView onAppear")
            print("### \(self.tab) ConversationsView onAppear")
//            viewStore.send(.tabViewIsHidden)
            ViewStore(store.stateless).send(.conversation(.onAppear))
          }
          .onDisappear {
//            self.isHidden.toggle()
            print("### \(self.isHidden) ConversationsView onDisAppear")
            viewStore.send(.tabViewIsHidden(true))
          }
        }
        .tabItem {
          Image(systemName: "bubble.left.and.bubble.right")
          Text("Chat")
        }
        .tag(Tab.conversation)

        NavigationView {
          ProfileView(
            store: store.scope(state: \.profile, action: TabsAction.profile)
          )
          .onAppear {
//            viewStore.send(.tabViewIsHidden)
            ViewStore(store.stateless).send(.profile(.onAppear))
          }
          .onDisappear {
            viewStore.send(.tabViewIsHidden(true))
          }
        }
        .tabItem {
          Image(systemName: "person")
          Text("Profile")
        }
        .tag(Tab.profile)

      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

// struct TabsView_Previews: PreviewProvider {
//  static let tabsEnv = TabsEnvironment(
//    backgroundQueue: .immediate,
//    mainQueue: .immediate,
//    webSocketClient: .live
//  )
//
//  static let tabsState = TabsState(
//    selectedTab: .event,
//    event: EventsState.placeholderEvents,
//    conversations: ConversationsState.placholderConversations,
//    profile: ProfileState()
//  )
//
//  static let store = Store(
//    initialState: tabsState,
//    reducer: tabsReducer,
//    environment: tabsEnv
//  )
//
//  static var previews: some View {
//    TabsView(store: store)
//  }
// }
