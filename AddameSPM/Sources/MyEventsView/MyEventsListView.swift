//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 15.06.2022.
//

import SwiftUI
import ComposableArchitecture
import AddaSharedModels

public struct MyEventsListView: View {
    let store: StoreOf<MyEvents>

    public init(store: StoreOf<MyEvents>) {
        self.store = store
    }

  public var body: some View {

    WithViewStore(self.store) { viewstore in
      VStack {
        Text("My Events").font(.title)
        ForEachStore(
            self.store.scope(state: \.myEvents, action: MyEvents.Action.event)
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
