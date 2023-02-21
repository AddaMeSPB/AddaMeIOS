//
//  ChatRowView.swift
//
//
//  Created by Saroar Khandoker on 17.06.2021.
//

import AsyncImageLoder
import ComposableArchitecture
import KeychainClient
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

public struct ChatRow: ReducerProtocol {
    public typealias State = MessageItem

    public enum Action: Equatable {}

    public var currentUser: UserOutput

    public init(currentUser: UserOutput) {
        self.currentUser = currentUser

        do {
            self.currentUser = try self.keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
        } catch {}
    }

    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {}
    }
}

struct ChatRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<ChatRow>
    
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build
    
    @ViewBuilder func currentUserRow(
        viewStore: ViewStore<MessageItem, ChatRow.Action>
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
        viewStore: ViewStore<MessageItem, ChatRow.Action>
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
                if isCurrentUser(userId: viewStore.sender!.id.hexString) {
                    opponentUsersRow(viewStore: viewStore)
                        .listRowSeparatorHidden()
                } else {
                    currentUserRow(viewStore: viewStore)
                        .listRowSeparatorHidden()
                }
            }
        }
    }
    
    func isCurrentUser(userId: String) -> Bool {
        do {
            let currentUSER = try keychainClient.readCodable(.user, build.identifier(), UserOutput.self)
            return currentUSER.id.hexString == userId ? true : false
        } catch {
            return false
        }
    }
}
