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
import AppDelegate
import UIKit

public struct TabsView: View {

    public struct ViewState: Equatable {
        public init(state: TabState) {
            self.selectedTab = state.selectedTab
            self.isHidden = state.isHidden
            self.unreadMessageCount = state.unreadMessageCount
        }

      public var selectedTab: TabState.Tab
      public var isHidden = false
      public var unreadMessageCount: Int
  }

  public enum ViewAction: Equatable {
    case onAppear
    case didSelectTab(TabState.Tab)
    case tabViewIsHidden(Bool)
  }

  @Environment(\.scenePhase) private var scenePhase
  let store: Store<TabState, TabAction>

  public init(store: Store<TabState, TabAction>) {
    self.store = store
  }

  @State var isHidden = false
  @State var tab: TabState.Tab = .event

  public var body: some View {
      WithViewStore(self.store, observe: ViewState.init, send: TabAction.init) { viewStore in

      HidableTabView(
        isHidden: viewStore.binding(get: { $0.isHidden }, send: ViewAction.tabViewIsHidden),
        selection: viewStore.binding(get: { $0.selectedTab }, send: ViewAction.didSelectTab)
      ) {
        NavigationView {
          EventView(
            store: store.scope(state: \.event, action: TabAction.event)
          )
          .onAppear {
            ViewStore(store.stateless).send(.event(.onAppear))
          }

        }
        .tabItem {
          Image(systemName: "list.bullet.below.rectangle")
          Text("Event")
        }
        .tag(TabState.Tab.event)

        NavigationView {
          ConversationsView(
            store: store.scope(state: \.conversations, action: TabAction.conversation)
          )
          .onAppear {
            self.isHidden = false
            print("\(#line) \(self.isHidden) ConversationsView onAppear")
            print("### \(self.tab) ConversationsView onAppear")
//            viewStore.send(.tabViewIsHidden)
            ViewStore(store.stateless).send(.conversation(.onAppear))
          }
          .onDisappear {
//            self.isHidden.toggle()
              print("### \(self.isHidden) ConversationsView onDisAppear")
              ViewStore(store.stateless).send(.tabViewIsHidden(true))
          }
        }
        .tabItem {
          Image(systemName: "bubble.left.and.bubble.right")
          Text("Chat")
        }
        .tag(TabState.Tab.conversation)

        NavigationView {
          ProfileView(
            store: store.scope(state: \.profile, action: TabAction.profile)
          )
          .onAppear {
//            viewStore.send(.tabViewIsHidden)
            ViewStore(store.stateless).send(.profile(.onAppear))
          }
          .onDisappear {
              ViewStore(store.stateless).send(.tabViewIsHidden(true))
          }
        }
        .tabItem {
          Image(systemName: "person")
          Text("Profile")
        }
        .tag(TabState.Tab.profile)

      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .onChange(of: self.scenePhase) {
          ViewStore(store.stateless).send(.scenePhase($0))
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
