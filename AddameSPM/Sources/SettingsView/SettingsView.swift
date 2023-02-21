//
//  SwiftUIView.swift
//
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import ComposableArchitecture
import KeychainClient
import SwiftUI
import ComposableUserNotifications
import AuthenticationView

// extension SettingsView {
//  public struct ViewState: Equatable {
//    public var alert: AlertState<SettingsAction>?
//    public var userNotificationSettings: UserNotificationClient.Notification.Settings?
//    public var userSettings: UserSettings
//    public var distance: DistanceState
//  }
//
//  public enum ViewAction: Equatable {
//    case leaveUsAReviewButtonTapped
//    case onAppear
//    case onDismiss
//    case distanceView(DistanceAction)
//    case resetAuthData
//    case deleteMeButtonTapped
//    case isLogoutButton(tapped: Bool)
//    case termsSheet(isPresented: Bool, url: String?)
//    case privacySheet(isPresented: Bool, url: String?)
//  }
// }

// public struct SettingsView: View {
//  let store: Store<SettingsState, SettingsAction>
//
//  public init(store: Store<SettingsState, SettingsAction>) {
//    self.store = store
//  }
//
//  public var body: some View {
//    WithViewStore(
//      self.store.scope(
//        state: { $0.view },
//        action: SettingsAction.view
//      )
//    ) { viewStore in
//      VStack {
//        VStack(alignment: .leading, spacing: 20) {
//          Text("Settings")
//            .font(.title)
//            .bold()
//            .padding()
//
////        Toggle(isOn:
////          viewStore.binding(
////            get: \.distanceTypeToggleisOn,
////            send: ViewAction.distanceTypeToggleChanged
////          )
////        ) {
////          Text("Remote Notifications")
////            .font(.system(.title2, design: .rounded))
////            .bold()
////            .foregroundColor(
////                viewStore.distanceTypeToggleisOn == true ? .green : .gray
////             )
////        }
////        .padding()
//
//          DistanceFilterView(
//            store: self.store.scope(
//              state: \.distance,
//              action: SettingsAction.distanceView
//            )
//          )
//          .padding([.top, .bottom], 20)
//          .transition(.opacity)
//
//          HStack {
//            Spacer()
//            Button(
//              action: {
//                viewStore.send(.termsSheet(isPresented: true, url: "https://addame.com/terms") )
//              },
//              label: {
//                Text("Terms")
//                  .font(.title)
//                  .bold()
//                  .foregroundColor(.blue)
//                  .padding()
//              })
//
//            Text("&")
//              .font(.title3)
//              .bold()
//              .padding([.leading, .trailing], 10)
//              .foregroundColor(Color(UIColor.systemBackground))
//
//            Button(
//              action: { viewStore.send(.termsSheet(isPresented: true, url: "https://addame.com/privacy") ) },
//              label: {
//                Text("Privacy")
//                  .font(.title)
//                  .bold()
//                  .foregroundColor(.blue)
//                  .padding()
//              })
//
//            Spacer()
//          }
//          // .frame(width: .infinity, height: 100, alignment: .center)
//          .background(Color.yellow)
//          .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
//          .padding()
//
//          Spacer()
//        }
//
//        HStack {
//            Button {
//                viewStore.send(.deleteMeButtonTapped)
//            } label: {
//              Text("Delete")
//                .font(.body)
//                .bold()
//            }
//            .padding(10)
//            .background(Color.yellow)
//            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
//            .padding([.bottom, .leading], 20)
//
//          Spacer()
//          Button {
//            viewStore.send(.isLogoutButton(tapped: true))
//          } label: {
//            Text("Logout")
//              .font(.body)
//              .bold()
//          }
//          .padding(10)
//          .background(Color.yellow)
//          .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
//          .padding([.bottom, .trailing], 20)
//        }
//      }
//      .sheet(
//        store.scope(state: \.termsAndPrivacyState, action: SettingsAction.termsAndPrivacy),
//        mapState: replayNonNil(),
//        onDismiss: {
//          ViewStore(store.stateless)
//            .send(.termsSheet(isPresented: false, url: nil))
//        },
//        content: TermsAndPrivacyWebView.init(store:)
//      )
//
////      .sheet(
////        store.scope(
////          state: \.terms,
////          action: SettingsAction.terms
////        ),
////        state: replayNonNil(),
////        onDismiss: { ViewStore(store.stateless)
////          .send(.termsView(isPresented: false))
////        },
////        destination: HangoutDetailsFeature.init(store:)
////      )
//    }
//    .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
//  }
// }

// struct SettingsView_Previews: PreviewProvider {
//  static let env = SettingsEnvironment(
//    applicationClient: .noop,
//    backgroundQueue: .immediate,
//    mainQueue: .immediate,
//    userDefaults: .noop,
//    userNotifications: .noop
//  )
//
//  static let store = Store(
//    initialState: SettingsState.settingsSatate,
//    reducer: settingsReducer,
//    environment: env
//  )
//
//  static var previews: some View {
//    Group {
//      SettingsView(store: store)
//      SettingsView(store: store)
//        .environment(\.colorScheme, .dark)
//    }
//  }
// }
