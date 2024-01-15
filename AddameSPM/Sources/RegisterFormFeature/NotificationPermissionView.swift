import SwiftUI
import SwiftUIHelpers
import AddaSharedModels
import UserDefaultsClient
import ComposableArchitecture
import ComposableUserNotifications

extension Color {
    static let customLavender = Color(red: 0.9, green: 0.8, blue: 1.0, opacity: 1.0)
}


struct NotificationPermissionView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<RegisterFormReducer>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
        VStack(alignment: .center) {
            Circle()
                .strokeBorder(Color.indigo, lineWidth: 5)
                .background(
                    Circle()
                        .strokeBorder(Color.teal.opacity(0.8), lineWidth: 5)
                        .frame(width: 220, height: 220)
                        .background(
                            Circle()
                                .strokeBorder(Color.customLavender, lineWidth: 5)
                                .frame(width: 130, height: 130)
                                .background(
                                    Image(systemName: "bell.and.waves.left.and.right")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.backgroundColor(for: colorScheme))

                                )
                        )
                )
                .frame(width: 300, height: 300)
                .padding(.top, 50)

            Text("Get conversations notification from group you already joined.")
                .font(Font.system(size: 30, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()

            Spacer()


            Button {
                viewStore.send(.isNotificationContinueButtonTapped, animation: .easeInOut)
            } label: {
                HStack {
                    Text("Continue")
                        .font(Font.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(height: 10, alignment: .center)
                        .padding(10)

                    Image(systemName: "bell.and.waves.left.and.right")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .font(Font.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                }
                .padding(15)
            }
            .background(Color.orange)
            .clipShape(Capsule())
            .frame(height: 40, alignment: .center)
            .padding(.bottom, 50)

        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

  }
}

#if DEBUG
struct NotificationPermissionView_Previews: PreviewProvider {
    static var store = Store(
        initialState: RegisterFormReducer.State()
    ) {
        RegisterFormReducer()
    }

    static var previews: some View {
        NotificationPermissionView(store: store)
    }
}
#endif
