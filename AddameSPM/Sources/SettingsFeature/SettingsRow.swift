import SwiftUI

public struct SettingsRow<Content>: View where Content: View {
  @Environment(\.colorScheme) var colorScheme
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    VStack(alignment: .leading) {
      self.content()
        .padding([.top, .bottom])
      Rectangle()
        .fill(Color.hex(self.colorScheme == .dark ? 0x7d7d7d : 0xEEEEEE))
        .frame(maxWidth: .infinity, minHeight: 2, idealHeight: 2, maxHeight: 2)
    }
    .padding(.horizontal)
  }
}
