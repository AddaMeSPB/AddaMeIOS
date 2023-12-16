//
//  ContactRow.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 04.12.2020.
//

import AsyncImageLoder
import ComposableArchitecture
import CoreDataStore
import AddaSharedModels
import SwiftUI
import FoundationExtension

public struct ContactRowView: View {
  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<ContactRow>
  @State var isClick: Bool = false

  public init(store: StoreOf<ContactRow>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack(spacing: 0) {
        if let avatar = viewStore.contact.avatar {
          AsyncImage(
            url: avatar.url,
            placeholder: {
              Text("Loading...").frame(width: 100, height: 100, alignment: .center)
            },
            image: {
              Image(uiImage: $0).resizable()
            }
          )
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 50)
          .clipShape(Circle())
          .padding(.trailing, 5)
        } else {
          Image(systemName: "person.fill")
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .foregroundColor(Color.backgroundColor(for: self.colorScheme))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 1))
            .padding(.trailing, 5)
        }

        VStack(alignment: .leading, spacing: 5) {

          if viewStore.contact.fullName != nil {
            Text(viewStore.contact.fullName ?? "unknown")
                  .lineLimit(1)
                  .font(.system(size: 18, weight: .semibold, design: .rounded))
          }

          Text(viewStore.contact.phoneNumber)
           .lineLimit(1)
           .font(.system(size: 14, weight: .light, design: .rounded))
           .foregroundColor(Color(.systemBlue))
        }
        .padding(5)

        Spacer()
        Button {
//          viewStore.send(.moveToChatRoom(true))
          viewStore.send(
            .chatWith(
              name: viewStore.contact.fullName ?? "unknow",
              phoneNumber: viewStore.contact.phoneNumber)
          )
        } label: {
          if #available(iOS 15.0, *) {
            Image(systemName: "bubble.left.and.bubble.right")
              .opacity(viewStore.isMoving ? 0 : 1)
              .overlay(ProgressView().opacity(viewStore.isMoving ? 1 : 0))
          } else {
            Image(systemName: "bubble.left.and.bubble.right")
              .opacity(isClick ? 0 : 1)
          }
        }
        .buttonStyle(BorderlessButtonStyle())
      }
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
      .padding(2)
    }
  }

  @available(iOSApplicationExtension, unavailable)
  func invite() {
    let url = URL(string: "https://testflight.apple.com/join/gXWnCqLB")
    let viewControllerToPresent = UIActivityViewController(
      activityItems: [url!], applicationActivities: nil)
    _ = UIApplication.shared.windows.first?.rootViewController?.present(
      viewControllerToPresent, animated: true, completion: nil
    )

    // ActivityView(activityItems: [URL(string: "https://testflight.apple.com/join/gXWnCqLB")!])
    // .ignoresSafeArea()
  }
}

// struct ContactRow_Previews: PreviewProvider {
//  static var previews: some View {
//    ContactRow(contact: <#ContactEntity#>)
//  }
// }
