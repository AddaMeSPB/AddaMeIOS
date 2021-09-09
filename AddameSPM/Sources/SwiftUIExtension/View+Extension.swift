//
//  View+Extension.swift
//  
//
//  Created by Saroar Khandoker on 12.11.2021.
//

import SwiftUI

extension View {

  @ViewBuilder public func listRowSeparatorHidden() -> some View {
    if #available(iOS 15.0, *) {
      self.listRowSeparator(.hidden)
    } else { // ios 14
      self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
          .listRowInsets(EdgeInsets(top: -1, leading: 16, bottom: -1, trailing: 16))
          .background(Color(.systemBackground))
    }
  }

  @ViewBuilder public func stackNavigationViewStyle() -> some View {
    if #available(iOS 15.0, *) {
      self.navigationViewStyle(.stack)
    } else {
      self.navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
