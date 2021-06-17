//
// ResignKeyboardOnDragGesture.swift
//  
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import SwiftUI
import Foundation

public extension UIApplication {
  func endEditing(_ force: Bool) {
    self.windows
      .first(where: { $0.isKeyWindow == true })?
      .endEditing(force)
  }
}

public struct ResignKeyboardOnDragGesture: ViewModifier {
  public var gesture = DragGesture().onChanged {_ in
    UIApplication.shared.endEditing(true)
  }

  public func body(content: Content) -> some View {
    content.gesture(gesture)
  }
}

public extension View {
  func resignKeyboardOnDragGesture() -> some View {
    return modifier(ResignKeyboardOnDragGesture())
  }
}
