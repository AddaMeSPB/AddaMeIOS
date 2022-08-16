//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 15.06.2022.
//

import SwiftUI
import ComposableArchitecture
import AddaSharedModels

public struct MyEventsState: Equatable {
    public init(
        isLoadingPage: Bool = false,
        canLoadMorePages: Bool = true,
        currentPage: Int = 1,
        index: Int = 0,
        myEvents: IdentifiedArrayOf<EventResponse> = []
    ) {
        self.isLoadingPage = isLoadingPage
        self.canLoadMorePages = canLoadMorePages
        self.currentPage = currentPage
        self.index = index
        self.myEvents = myEvents
    }

    public var isLoadingPage = false
    public var canLoadMorePages = true
    public var currentPage = 1
    public var index = 0
    public var myEvents: IdentifiedArrayOf<EventResponse> = []
}

public struct MyEventsListView: View {
    public init(store: Store<MyEventsState, MyEventsAction>) {
        self.store = store
    }

  let store: Store<MyEventsState, MyEventsAction>

  public var body: some View {

    WithViewStore(self.store) { viewstore in
      VStack {
        Text("My Events").font(.title)
        ForEachStore(
          self.store.scope(state: \.myEvents, action: MyEventsAction.event)
        ) { eventStore in
          WithViewStore(eventStore) { _ in
            // Button(action: { viewStore.send(.eventTapped(eventViewStore.state)) }) {
              MyEventRowView(store: eventStore)
            // }
            // .buttonStyle(PlainButtonStyle())
          }
  //        .padding([.leading, .trailing], 30)
        }
      }
      .onAppear { viewstore.send(.onApper) }
    }
  }
}
