//
//  ColorSchemeExtension.swift
//
//
//  Created by Saroar Khandoker on 02.02.2021.
//

import SwiftUI

extension Color {

  public static func backgroundColor(for colorScheme: ColorScheme) -> Color {
    if colorScheme == .dark {
      return Color(white: 1.0)
    } else {
      return Color(white: 0.0)
    }
  }
}

// USE case
struct ColoredView: View {
  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var body: some View {
    Rectangle().fill(Color.backgroundColor(for: self.colorScheme))
  }
}

struct ColoredView_Previews: PreviewProvider {
  static var previews: some View {
    ColoredView()
  }
}
