import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import Build
import SwiftUIExtension

public struct SettingsView: View {

    @Environment(\.colorScheme) var colorScheme
    @State var isSharePresented = false
    let store: StoreOf<Settings>
    @ObservedObject var viewStore: ViewStore<ViewState, Settings.Action>

    struct ViewState: Equatable {
        let buildNumber: Build.Number?
        let currentUser: UserOutput
        let distanceState: Distance.State

      init(state: Settings.State) {
          self.buildNumber = state.buildNumber
          self.currentUser = state.currentUser
          self.distanceState = state.distanceState
      }
    }

    public init(store: StoreOf<Settings>) {
      self.store = store
      self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }

  public var body: some View {
      VStack {
          VStack {
//              Text("Hello, \(self.viewStore.currentUser.fullName)")
//                  .frame( maxWidth: .infinity, alignment: .leading)
//                  .font(Font.system(size: 30, weight: .heavy, design: .rounded))

              Text("Support our app")
                  .frame( maxWidth: .infinity, alignment: .leading)
                  .font(Font.system(size: 16, weight: .light, design: .rounded))

          }
          .padding(.horizontal)
          .padding(.bottom, 10)

          ScrollView(.horizontal, showsIndicators: false) {
              HStack {
                  VStack {
                      Button(action: {
                          self.viewStore.send(.leaveUsAReviewButtonTapped)
                      }) {
                          VStack {
                              Image(systemName: "hand.thumbsup")
                                  .resizable()
                                  .frame(width: 100, height: 100)
                                  .scaledToFit()
                                  .padding(.top, 20)
                                  .padding(.vertical)

                              Text("Leave us review")
                                  .font(.title3)
                                  .bold()
                                  .frame(maxWidth: .infinity, alignment: .center)
                                  .padding()

                          }
                      }
                      .background(colorScheme == .dark ? Color.gray : Color.blue)
                      .cornerRadius(20)
                      .shadow(radius: 10)
                      .frame(width: 230)

                  }
                  .foregroundColor(.white)
                  .background(Color.blue)
                  .cornerRadius(20)
                  .padding(.horizontal)

                  VStack {
                      Button(action: { self.isSharePresented.toggle() }) {
                          VStack {
                              Image(systemName: "allergens")
                                  .resizable()
                                  .frame(width: 100, height: 100)
                                  .scaledToFit()
                                  .padding(.top, 20)
                                  .padding(.vertical)

                              Text("Share with a friend!")
                                  .font(.title3)
                                  .bold()
                                  .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                  .padding()
                          }
                      }
                      .background(colorScheme == .dark ? Color.gray : Color.blue)
                      .cornerRadius(20)
                      .shadow(radius: 10)
                      .frame(width: 230)
                  }
                  .foregroundColor(.white)
                  .background(Color.blue)
                  .cornerRadius(20)

              }
          }

          SettingsNavigationLink(
            destination: NotificationsSettingsView(store: self.store),
            title: "Notifications"
          )

          SettingsNavigationLink(
            destination: DistanceFilterView(
                store: self.store.scope(
                state: \.distanceState,
                action: Settings.Action.distance)
            ),
            title: "Distance"
          )

          Spacer()

          HStack {
              Spacer()

              Button(action: { self.viewStore.send(.logOutButtonTapped) }) {
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
            if let buildNumber = self.viewStore.buildNumber {
              Text("Build \(buildNumber.rawValue)")
            }
            Button(action: { self.viewStore.send(.reportABugButtonTapped) }) {
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
      .alert(self.store.scope(state: \.alert), dismiss: .set(\.$alert, nil))
      .sheet(isPresented: self.$isSharePresented) {
        ActivityView(activityItems: [URL(string: "https://apps.apple.com/ru/app/new-word-learn-word-vocabulary/id1619504857?l=en")!])
          .ignoresSafeArea()
      }
      .padding(.vertical)
      .frame(maxWidth: .infinity)

  }

}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(
            initialState: Settings.State(),
            reducer: Settings())
        )
    }
}
