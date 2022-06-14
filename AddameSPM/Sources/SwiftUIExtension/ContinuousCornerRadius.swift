import SwiftUI

extension View {
  public func continuousCornerRadius(_ radius: CGFloat) -> some View {
    clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
  }
}
