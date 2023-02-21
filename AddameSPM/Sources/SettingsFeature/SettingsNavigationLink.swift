import SwiftUI

struct SettingsNavigationLink<Destination>: View where Destination: View {
  let destination: Destination
  let title: LocalizedStringKey

  var body: some View {
    SettingsRow {
      NavigationLink(
        destination: self.destination,
        label: {
          HStack {
            Text(self.title)
                  .font(.system(size: 20, design: .rounded))

            Spacer()
            Image(systemName: "arrow.right")
                  .font(.system(size: 20, design: .rounded))
          }
        }
      )
    }
  }
}
