//
//  ChatRowView.swift
//
//
//  Created by Saroar Khandoker on 17.06.2021.
//

import AsyncImageLoder
import ComposableArchitecture
import HTTPRequestKit
import KeychainService
import AddaSharedModels
import SwiftUI
import SwiftUIExtension

struct AvatarView: View {
  @Environment(\.colorScheme) var colorScheme
  let avatarUrl: String?

  var body: some View {
      if avatarUrl != nil {
        if #available(iOS 15.0, *) {
            AsyncImage(url: URL(string: avatarUrl!)!) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40, maxHeight: 40)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    // Since the AsyncImagePhase enum isn't frozen,
                    // we need to add this currently unused fallback
                    // to handle any new cases that might be added
                    // in the future:
                    EmptyView()
                }
            }
        } else {
            AsyncImage(
              url: URL(string: avatarUrl!)!,
              placeholder: { Text("Loading...").frame(width: 40, height: 40, alignment: .center) },
              image: {
                Image(uiImage: $0).resizable()
              }
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }
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
  let store: Store<MessageItem, MessageAction>

  @ViewBuilder func currentUserRow(
    viewStore: ViewStore<MessageItem, MessageAction>
  ) -> some View {
    HStack {
      Group {
        AvatarView(avatarUrl: viewStore.sender?.lastAvatarURLString)

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
    viewStore: ViewStore<MessageItem, MessageAction>
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

        AvatarView(avatarUrl: viewStore.recipient?.lastAvatarURLString)
      }
    }
    .background(Color(.systemBackground))
  }

    @ViewBuilder
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if isCurrentUser(userId: viewStore.sender!.id!.hexString) {
                    opponentUsersRow(viewStore: viewStore)
                        .listRowSeparatorHiddenIfAvaibale()
                } else {
                    currentUserRow(viewStore: viewStore)
                        .listRowSeparatorHiddenIfAvaibale()
                }
            }
        }
    }

    private func isCurrentUser(userId: String) -> Bool {
        if let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) {
            return currentUSER.id!.hexString == userId ? true : false
        }
        return false
    }
}
