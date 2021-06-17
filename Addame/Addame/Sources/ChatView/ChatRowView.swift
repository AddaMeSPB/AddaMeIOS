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


struct ChatRowView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: Store<ChatMessageResponse.Item, MessageAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {

        if !currenuser(viewStore.sender.id) {
          HStack {
            Group {

              if viewStore.sender.avatarUrl != nil {
                AsyncImage(
                  urlString: viewStore.sender.avatarUrl,
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
        } else {
          HStack {
            Group {
              Spacer()
              Text(viewStore.messageBody)
                .bold()
                .foregroundColor(Color.white)
                .padding(10)
                .background(Color.red)
                .cornerRadius(10)

              if viewStore.sender.avatarUrl != nil {
                AsyncImage(
                  urlString: viewStore.sender.avatarUrl,
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
          .background(Color(.systemBackground))
        }
      }
      .background(Color(.systemBackground))
    }
  }

  func currenuser(_ userId: String) -> Bool {
      guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
        return false
      }

      return currentUSER.id == userId ? true : false

    }
}
