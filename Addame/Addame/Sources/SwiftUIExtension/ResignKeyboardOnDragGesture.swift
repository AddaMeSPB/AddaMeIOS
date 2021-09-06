//
// ResignKeyboardOnDragGesture.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Foundation
import SwiftUI

extension UIApplication {
  public func endEditing(_ force: Bool) {
    windows
      .first(where: { $0.isKeyWindow == true })?
      .endEditing(force)
  }
}

@available(iOSApplicationExtension, unavailable)
public struct ResignKeyboardOnDragGesture: ViewModifier {
  public var gesture = DragGesture().onChanged { _ in
    UIApplication.shared.endEditing(true)
  }

  public func body(content: Content) -> some View {
    content.gesture(gesture)
  }
}

@available(iOSApplicationExtension, unavailable)
extension View {
  public func resignKeyboardOnDragGesture() -> some View {
    return modifier(ResignKeyboardOnDragGesture())
  }
}
