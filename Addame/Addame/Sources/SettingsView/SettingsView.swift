//
//  SwiftUIView.swift
//  
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import SwiftUI
import KeychainService
import UserNotificationClient
import ComposableArchitecture

extension SettingsView {
  public struct ViewState: Equatable {
    public var alert: AlertState<SettingsAction>?
    public var userNotificationSettings: UserNotificationClient.Notification.Settings?
    public var userSettings: UserSettings
    public var distance: DistanceState
  }

  public enum ViewAction: Equatable {
    case leaveUsAReviewButtonTapped
    case onAppear
    case onDismiss
    case distanceView(DistanceAction)
  }
}

public struct SettingsView: View {

  let store: Store<SettingsState, SettingsAction>

  public init(store: Store<SettingsState, SettingsAction>) {
    self.store = store
  }

  public var body: some View {

    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: SettingsAction.view
      )
    ) { _ in
      VStack(alignment: .leading, spacing: 20) {

        Text("Settings")
          .font(.title)
          .bold()
          .padding()

//        Toggle(isOn:
//          viewStore.binding(
//            get: \.distanceTypeToggleisOn,
//            send: ViewAction.distanceTypeToggleChanged
//          )
//        ) {
//          Text("Remote Notifications")
//            .font(.system(.title2, design: .rounded))
//            .bold()
//            .foregroundColor(viewStore.distanceTypeToggleisOn == true ? .green : .gray)
//        }
//        .padding()

        DistanceFilterView(
          store: self.store.scope(
            state: \.distance,
            action: SettingsAction.distanceView
          )
        )
        .padding([.top, .bottom], 20)
        .transition(.opacity)

        HStack {
          Spacer()
          Button(action: {
            // showingTermsSheet = true
          }, label: {
            Text("Terms")
              .font(.title)
              .bold()
              .foregroundColor(.blue)
              .padding()
          })
          // .sheet(isPresented: $showingTermsSheet) {
          //  TermsAndPrivacyWebView(urlString: "" + "/terms")
          //  EnvironmentKeys.rootURL.absoluteString
          // }

          Text("&")
            .font(.title3)
            .bold()
            .padding([.leading, .trailing], 10)
            .foregroundColor(Color(UIColor.systemBackground))

          Button(action: {
            // showingPrivacySheet = true
          }, label: {
            Text("Privacy")
              .font(.title)
              .bold()
              .foregroundColor(.blue)
              .padding()
          })
          // .sheet(isPresented: $showingPrivacySheet) {
          //  TermsAndPrivacyWebView(urlString: "" + "/privacy") //EnvironmentKeys.rootURL.absoluteString
          // }

          Spacer()
        }
        // .frame(width: .infinity, height: 100, alignment: .center)
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .padding()

        Spacer()

      }
    }
    .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
  }
}

struct SettingsView_Previews: PreviewProvider {

  static let env = SettingsEnvironment(
    applicationClient: .noop,
    backgroundQueue: .immediate,
    mainQueue: .immediate,
    userDefaults: .noop,
    userNotifications: .noop
  )

  static let store = Store(
    initialState: SettingsState.settingsSatate,
    reducer: settingsReducer,
    environment: env
  )

  static var previews: some View {
    Group {
      SettingsView(store: store)
      SettingsView(store: store)
        .environment(\.colorScheme, .dark)
    }
  }
}
