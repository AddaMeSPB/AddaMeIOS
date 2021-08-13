//
//  ChatRowView.swift
//  
//
//  Created by Saroar Khandoker on 17.06.2021.
//

import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import KeychainService
import AsyncImageLoder
import SwiftUIExtension

struct AvatarView: View {
  @Environment(\.colorScheme) var colorScheme
  let avatarUrl: String?

  var body: some View {
    if avatarUrl != nil {
      AsyncImage(
        urlString: avatarUrl,
        placeholder: { Text("Loading...").frame(width: 40, height: 40, alignment: .center) },
        image: {
        Image(uiImage: $0).resizable()
        }
      )
        .aspectRatio(contentMode: .fit)
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    } else {
      Image(systemName: "person.fill")
        .font(.title2)
        .aspectRatio(contentMode: .fit)
        .frame(width: 40, height: 40)
        .foregroundColor(Color.backgroundColor(for: self.colorScheme))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black, lineWidth: 1))
    }
  }
}

struct ChatRowView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: Store<ChatMessageResponse.Item, MessageAction>

  @ViewBuilder func currentUserRow(viewStore: ViewStore<ChatMessageResponse.Item, MessageAction>) -> some View {
    HStack {
      Group {

        AvatarView(avatarUrl: viewStore.sender.avatarUrl)

        Text(viewStore.messageBody)
          .bold()
          .padding(10)
          .foregroundColor(Color.white)
          .background(Color.blue)
          .cornerRadius(10)
      }
      .background(Color(.systemBackground))
      Spacer()
    }
    .background(Color(.systemBackground))

  }

  @ViewBuilder func opponentUsersRow(
    viewStore: ViewStore<ChatMessageResponse.Item, MessageAction>
  ) -> some View {
    HStack {
      Group {
        Spacer()
        Text(viewStore.messageBody)
          .bold()
          .foregroundColor(Color.white)
          .padding(10)
          .background(Color.red)
          .cornerRadius(10)

        AvatarView(avatarUrl: viewStore.recipient?.avatarUrl)

      }
    }
    .background(Color(.systemBackground))
  }

  @ViewBuilder
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        if !currenuser(viewStore.sender.id) {
          if #available(iOS 15.0, *) {
            currentUserRow(viewStore: viewStore)
              .listRowSeparator(.hidden)
          } else {
            currentUserRow(viewStore: viewStore)
          }
        } else {
          if #available(iOS 15.0, *) {
            opponentUsersRow(viewStore: viewStore)
            .listRowSeparator(.hidden)
          } else {
            opponentUsersRow(viewStore: viewStore)
          }
        }
      }
    }
  }

  func currenuser(_ userId: String) -> Bool {
    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
      return false
    }

    return currentUSER.id == userId ? true : false
  }

}
