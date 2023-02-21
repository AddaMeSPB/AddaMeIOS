import ComposableArchitecture
import SwiftUI
import FoundationExtension

struct NotificationsSettingsView: View {
  let store: StoreOf<Settings>
  @ObservedObject var viewStore: ViewStoreOf<Settings>

  init(store: StoreOf<Settings>) {
    self.store = store
    self.viewStore = ViewStore(self.store)
  }

  var body: some View {
    SettingsForm {
      SettingsRow {
        Toggle(
          "Enable notifications", isOn: self.viewStore.binding(\.$enableNotifications).animation()
        )
        .font(.system(size: 16, design: .rounded))
          Text("*** Please dont turn off notification then whole function will be turn off")
              .font(.system(size: 13, design: .rounded))
              .foregroundColor(.red)
              .padding(.top, -20)
      }
    }
    .navigationTitle("Notifications")
  }
}

public struct SettingsForm<Content>: View where Content: View {
  @Environment(\.colorScheme) var colorScheme
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    ScrollView {
      self.content()
        .font(.system(size: 15, design: .rounded))
//        .toggleStyle(SwitchToggleStyle(tint: .isowordsOrange))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

