import SwiftUI
import ComposableArchitecture
import ComposableUserNotifications
import UserDefaultsClient
import AddaSharedModels
import UserNotifications
import URLRouting
import APIClient
import Combine
import SwiftUIHelpers
import LocationReducer

public struct RegisterFormView: View {

    let store: StoreOf<RegisterFormReducer>

    public init(store: StoreOf<RegisterFormReducer>) {
        self.store = store
    }

  struct ViewState: Equatable {

    @BindingState var selectedPage: FormTag
    var waitingForLoginView: Bool
    var locationState: LocationReducer.State?

    public init(state: RegisterFormReducer.State) {
        self.selectedPage = state.selectedPage
        self.waitingForLoginView = state.waitingForLoginView
        self.locationState = state.locationState
    }

  }

  public var body: some View {
      WithViewStore(self.store, observe: ViewState.init) { viewStore in
      ZStack(alignment: .bottomTrailing) {
              TabView(
                selection: viewStore.binding(
                    get: \.selectedPage,
                    send: RegisterFormReducer.Action.selectedPage
                )
              ) {
                  NotificationPermissionView(store: store).tag(FormTag.notificationPermission)
                  LocationPermissionView(store: store).tag(FormTag.locationPermission)
                  IDFAPermissionView(store: store).tag(FormTag.IDFAPermission)
              }
              .tabViewStyle(.page(indexDisplayMode: .never))

      }
      .onAppear { viewStore.send(.onApper) }
      }
    ._printChanges()
  }

}

#if DEBUG
struct RegisterFormView_Previews: PreviewProvider {
    static var store = Store(
        initialState: RegisterFormReducer.State()
    ) {
        RegisterFormReducer()
    }

    static var previews: some View {
        RegisterFormView(store: store)
    }
}
#endif
