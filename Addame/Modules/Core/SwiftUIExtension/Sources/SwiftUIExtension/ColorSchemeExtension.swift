//
//  ColorSchemeExtension.swift
//  
//
//  Created by Saroar Khandoker on 02.02.2021.
//

import SwiftUI

public extension Color {

  static let lightBackgroundColor = Color(white: 1.0)

  static let darkBackgroundColor = Color(white: 0.0)

  static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return lightBackgroundColor
        } else {
            return darkBackgroundColor
        }
    }
}

// USE case
struct ColoredView : View {
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
