import SwiftUI
import SwiftUIHelpers
import AddaSharedModels
import UserDefaultsClient
import ComposableArchitecture
import ComposableUserNotifications

struct LocationPermissionView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<RegisterFormReducer>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
        VStack(alignment: .center) {
            Circle()
                .strokeBorder(Color.green, lineWidth: 5)
                .background(
                    Circle()
                        .strokeBorder(Color.yellow, lineWidth: 5)
                        .frame(width: 220, height: 220)
                        .background(
                            Image(systemName: "location")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.backgroundColor(for: colorScheme))
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
                viewStore.send(.isLocationEnableContinueButtonTapped, animation: .easeInOut)
            } label: {
                HStack {
                    Text("Continue")
                        .font(Font.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(height: 10, alignment: .center)
                        .padding(10)

                    Image(systemName: "location")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .font(Font.system(size: 30, weight: .medium))
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
struct LocationPermissionView_Previews: PreviewProvider {
    static var store = Store(
        initialState: RegisterFormReducer.State(),
        reducer: RegisterFormReducer()
    )

    static var previews: some View {
        LocationPermissionView(store: store)
    }
}
#endif

