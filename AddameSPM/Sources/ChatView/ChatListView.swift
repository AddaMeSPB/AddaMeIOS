//
//  ChatListView.swift
//
//
//  Created by Saroar Khandoker on 17.06.2021.
//

import ComposableArchitecture
import AddaSharedModels
import SwiftUI

// struct ChatListView: View {
//  let store: Store<ChatState, ChatAction>
//
//  var body: some View {
//    WithViewStore(
//      self.store.scope(
//        state: { $0.view },
//        action: ChatAction.view
//      )
//    ) { viewStore in
//      ForEachStore(
//        self.store.scope(state: \.messages, action: ChatAction.message)
//      ) { chatStore in
//        WithViewStore(chatStore) { messageViewStore in
//          ChatRowView(store: chatStore)
//            .onAppear {
//              viewStore.send(.fetchMoreMessageIfNeeded(currentItem: messageViewStore.state))
//            }
//            .scaleEffect(x: 1, y: -1, anchor: .center)
//            .listRowSeparatorHiddenIfAvaibale()
//        }
//      }
//    }
//  }
// }
