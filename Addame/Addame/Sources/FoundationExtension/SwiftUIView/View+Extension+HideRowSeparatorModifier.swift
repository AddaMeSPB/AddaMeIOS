//
//  View+Extension+HideRowSeparatorModifier.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 27.10.2020.
//

import SwiftUI

// public struct HideRowSeparatorModifier: ViewModifier {
//
//  public static let defaultListRowHeight: CGFloat = 44
//  public var insets: EdgeInsets
//  public var background: Color
//
//  public init(insets: EdgeInsets, background: Color) {
//    self.insets = insets
//    var alpha: CGFloat = 0
//
//    if #available(iOS 14.0, *) {
//      Color(background).getWhite(nil, alpha: &alpha)
//    } else {
//      Color.clear
//    }
//    assert(alpha == 1, "Setting background to a non-opaque color will result in separators remaining visible.")
//    self.background = background
//  }
//
//  public func body(content: Content) -> some View {
//    content
//      .padding(insets)
//      .frame(
//        minWidth: 0, maxWidth: .infinity,
//        minHeight: Self.defaultListRowHeight,
//        alignment: .leading
//      )
//      .listRowInsets(EdgeInsets())
//      .background(background)
//  }
// }
//
// public extension EdgeInsets {
//  static let defaultListRowInsets = Self(top: 0, leading: 16, bottom: 0, trailing: 16)
// }
//
// public extension View {
//  func hideRowSeparator(
//    insets: EdgeInsets = .defaultListRowInsets,
//    background: Color = Color(UIColor.systemBackground)
//  ) -> some View {
//    modifier(HideRowSeparatorModifier(
//      insets: insets,
//      background: background
//    ))
//  }
// }
