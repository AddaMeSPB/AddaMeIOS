//
//  ChatListView.swift
//
//
//  Created by Saroar Khandoker on 17.06.2021.
//

import ComposableArchitecture
import AddaSharedModels
import SwiftUI

struct ChatListView: View {
    let store: StoreOf<Chat>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ForEachStore(
                self.store.scope(
                    state: \.messages,
                    action: Chat.Action.message(index:action:)
                )
            ) { chatStore in
                WithViewStore(chatStore, observe: { $0 }) { messageViewStore in
                    ChatRowView(store: chatStore)
                        .onAppear {
                            viewStore.send(.fetchMoreMessageIfNeeded(currentItem: messageViewStore.state))
                        }
                        .scaleEffect(x: 1, y: -1, anchor: .center)
//                        .listRowSeparatorHiddenIfAvaibale()
                }
            }
        }
    }
}
