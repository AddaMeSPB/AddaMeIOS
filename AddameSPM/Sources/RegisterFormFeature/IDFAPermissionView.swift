import SwiftUI
import SwiftUIHelpers
import AddaSharedModels
import UserDefaultsClient
import ComposableArchitecture
import ComposableUserNotifications

struct IDFAPermissionView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<RegisterFormReducer>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
        VStack(alignment: .center) {


            Text("IDFA*")
                .font(Font.system(size: 40, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(Color.blue)

            Image(systemName: "lock.shield")
                .resizable()
                .frame(width: 200, height: 200)
                .foregroundColor(Color.green)
//                .foregroundColor(.backgroundColor(for: colorScheme))

            Text("We dont sell or send your data to any 3rd party. we will need you data to improve our service and fetch hangouts envets base on your current Location.")
                .font(Font.system(size: 30, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .padding()
//                .foregroundColor(Color.blue)

            Spacer()

            Button {
                viewStore.send(.isIDFAEbableContinueButtonTapped, animation: .easeInOut)
            } label: {
                HStack {
                    if !viewStore.waitingForLoginView {
                        Text("Continue")
                            .font(Font.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(height: 10, alignment: .center)
                            .padding(10)

                        Image(systemName: "lock.shield")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 10)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .padding(10)
                    }

                }
                .padding(10)
            }
            .background(Color.orange)
            .clipShape(Capsule())
            .frame(height: 40, alignment: .center)
            .padding(.bottom, 20)

            Text("* The identifier for advertisers (known as the IDFA) is a random device identifier assigned by Apple to a user’s device.")
                .font(Font.system(size: 15, weight: .light, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()

        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

  }
}

#if DEBUG
//struct IDFAPermissionView_Previews: PreviewProvider {
//    static var store = Store(
//        initialState: RegisterFormReducer.State(),
//        reducer: RegisterFormReducer()
//    )
//
//    static var previews: some View {
//        IDFAPermissionView(store: store)
//    }
//}
#endif


