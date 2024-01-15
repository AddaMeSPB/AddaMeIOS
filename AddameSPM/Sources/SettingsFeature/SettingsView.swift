import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import Build
import SwiftUIExtension

public struct SettingsView: View {

    @Environment(\.colorScheme) var colorScheme
    @State var isSharePresented = false
    let store: StoreOf<Settings>

    struct ViewState: Equatable {
        let buildNumber: Build.Number?
        let currentUser: UserOutput

      init(state: Settings.State) {
          self.buildNumber = state.buildNumber
          self.currentUser = state.currentUser
      }
    }

    private var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 250)), count: 2)
    }

    public init(store: StoreOf<Settings>) {
      self.store = store
    }

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
          VStack {
              Text("Hello, \(viewStore.currentUser.fullName ?? "")")
                  .frame( maxWidth: .infinity, alignment: .leading)
                  .font(Font.system(size: 30, weight: .heavy, design: .rounded))
                  .padding(.vertical, 5)

              Text("Support our app")
                  .frame( maxWidth: .infinity, alignment: .leading)
                  .font(Font.system(size: 16, weight: .light, design: .rounded))

          }
          .padding(.horizontal)
          .padding(.bottom, 10)

        LazyVGrid(columns: items, spacing: 10) {
          Button(action: {
            viewStore.send(.leaveUsAReviewButtonTapped)
          }) {
            VStack(alignment: .center, spacing: 5) {
              HStack { Spacer() }
                Image(systemName: "hand.thumbsup")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 65, height: 65)
                  .foregroundColor(.white)

              Text("Leave us review")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 5)

              Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
          }
//          .buttonStyle(.plain)
          .frame(height: 180)
          .background(Color.red.opacity(0.3))
          .cornerRadius(20)

          Button(action: {
            isSharePresented.toggle()
          }) {
            VStack(alignment: .center, spacing: 5) {
              HStack { Spacer() }
                Image(systemName: "square.and.arrow.up.circle")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 65, height: 65)
                  .foregroundColor(.blue)

              Text("Share with friends")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 5)

              Spacer()
            }
            .padding()
          }
//          .buttonStyle(.plain)
          .frame(height: 180)
          .background(Color.yellow.opacity(0.5))
          .cornerRadius(20)

        }
        .padding()

          Spacer()

          HStack {
              Spacer()

              Button(action: { viewStore.send(.logOutButtonTapped) }) {
                  Text("Log out!")
                      .font(.title3).fontWeight(.medium)
                      .foregroundColor(.white)
                      .padding(.horizontal)
              }
              .padding()
              .background(Color.red)
              .clipShape(Capsule())
          }
          .padding(.horizontal)

          VStack(spacing: 6) {
            if let buildNumber = viewStore.buildNumber {
              Text("Build \(buildNumber.rawValue)")
            }
            Button(action: { viewStore.send(.reportABugButtonTapped) }) {
              Text("Report a bug")
                .underline()
            }
          }
          .frame(maxWidth: .infinity)
          .padding()
          .font(.system(size: 12, design: .rounded))
      }
      .onAppear { viewStore.send(.onAppear) }
      .navigationTitle("Settings")
      .sheet(isPresented: self.$isSharePresented) {
        ActivityView(activityItems: [URL(string: "https://apps.apple.com/pt/app/walk-nearby-neighbours-friends/id1538487173?l=en-GB")!])
          .ignoresSafeArea()
      }
      .padding(.vertical)
      .frame(maxWidth: .infinity)
    }
  }

}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(
            initialState: Settings.State()
        ) {
            Settings()
        })
    }
}
