//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 15.06.2022.
//

import SwiftUI
import ComposableArchitecture
import AddaSharedModels

public struct MyEventRowView: View {
  @Environment(\.colorScheme) var colorScheme

  public init(store: Store<EventResponse, MyEventAction>) {
    self.store = store
  }

  public let store: Store<EventResponse, MyEventAction>

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        Group {
          Text(viewStore.name)
            .font(.system(.title, design: .rounded))
            .lineLimit(2)
            .padding(.top, 8)
            .padding(.bottom, 3)

          Text(viewStore.addressName)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.blue)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(
            colorScheme == .dark
              ? Color(
                #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1))
              : Color(
                #colorLiteral(
                  red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)))
      )
      .padding([.leading, .trailing], 16)
      .padding([.top, .bottom], 5)
    }
  }
}
