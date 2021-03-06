//
//  AuthenticationView.swift
//
//
//  Created by Saroar Khandoker on 07.04.2021.
//

import AuthClient
import ComposableArchitecture
import PhoneNumberKit
import SharedModels
import SwiftUI

public struct AuthenticationView: View {

  @State private var phoneField: PhoneNumberTextFieldView?
  @State private var isValidPhoneNumber: Bool = false
  @State private var phoneNumber = String.empty

  let store: Store<LoginState, LoginAction>

  public init(store: Store<LoginState, LoginAction>) {
    self.store = store
  }

  @ViewBuilder
  private func inputMobileNumberTextView(
    _ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>
  ) -> some View {
    HStack {
      phoneField.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
        .keyboardType(.phonePad)
        .padding(.leading)
        .disabled(viewStore.isLoginRequestInFlight)

      Button(
        action: {
          self.phoneField?.getCurrentText()
          viewStore.send(.sendPhoneNumberButtonTapped(self.phoneNumber))
        },
        label: {
          if !viewStore.isLoginRequestInFlight {
            Text("GO").font(.headline).bold().padding()
          } else {
            ProgressView()
              .accentColor(Color.black)
              .font(.headline)
              .padding()
            // color have to be black
          }
        }
      )
      .disabled(!self.isValidPhoneNumber || viewStore.isLoginRequestInFlight)
      .foregroundColor(self.isValidPhoneNumber ? Color.black : Color.white)
      .background(
        self.isValidPhoneNumber ? Color.yellow : Color.gray
      )
      .cornerRadius(50)

    }
    .overlay(
      RoundedRectangle(cornerRadius: 30)
        .stroke(Color.black.opacity(0.1), lineWidth: 0.6)
        .foregroundColor(
          Color(
            #colorLiteral(
              red: 0.8039215803,
              green: 0.8039215803,
              blue: 0.8039215803,
              alpha: 0.06563035103
            )
          )
        )
    )
    .onAppear {
      self.phoneField = PhoneNumberTextFieldView(
        phoneNumber: self.$phoneNumber,
        isValid: $isValidPhoneNumber
      )
    }
  }

  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: LoginAction.view)) { viewStore in
      ZStack(alignment: .top) {

        VStack {
          Text("Adda")
            .font(Font.system(size: 56, weight: .heavy, design: .rounded))
            .foregroundColor(.red)
            .padding(.top, 120)

          if !viewStore.isValidationCodeIsSend {
            Text("Register Or Login")
              .font(Font.system(size: 33, weight: .heavy, design: .rounded))
              .foregroundColor(.blue)
              .padding()
          }

          if viewStore.isValidationCodeIsSend {
            Text("Verification Code")
              .font(Font.system(size: 33, weight: .heavy, design: .rounded))
              .foregroundColor(.blue)
              .padding(.top, 10)
          }

          ZStack {
            if !viewStore.isValidationCodeIsSend {
              inputMobileNumberTextView(viewStore)
                .disabled(viewStore.isLoginRequestInFlight)
            }

            if viewStore.isValidationCodeIsSend {
              inputValidationCodeTextView(viewStore)
            }
          }
          .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))

          if !viewStore.isValidationCodeIsSend {
            termsAndPrivacyView(viewStore)
          }

          Spacer()
        }
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
    }
  }

  @ViewBuilder
  private func inputValidationCodeTextView(
    _ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>
  ) -> some View {
    VStack {
      HStack {
        TextField(
          "__ __ __ __ __ __",
          text: viewStore.binding(
            get: { $0.authResponse?.code ?? "" }, send: ViewAction.verificationRequest)
        )
        .font(.largeTitle)
        .multilineTextAlignment(.center)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
        .keyboardType(.phonePad)
        .padding(.leading)

      }.cornerRadius(25)
        .overlay(
          RoundedRectangle(cornerRadius: 25)
            .stroke(Color.black.opacity(0.2), lineWidth: 0.6)
            .foregroundColor(
              Color(
                #colorLiteral(
                  red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.06563035103))
            )
        )
    }
  }

  fileprivate func termsAndPrivacyView(
    _ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>
  ) -> some View {
    VStack {
      Text("Check our terms and privacy")
        .font(.body)
        .bold()
        .foregroundColor(.blue)
        .padding()

      HStack {
        Button(
          action: {
            viewStore.send(.showTermsSheet)
          },
          label: {
            Text("Terms")
              .font(.title3)
              .bold()
              .foregroundColor(.blue)
          }
        )
        .sheet(
          isPresented: viewStore.binding(
            get: { $0.showTermsSheet },
            send: { _ -> ViewAction in
              .showTermsSheet
            })
        ) {
          // TermsAndPrivacyWebView(urlString: baseURL.appendingPathComponent("/terms").absoluteString)
        }

        Text("&")
          .font(.title3)
          .bold()
          .padding([.leading, .trailing], 10)

        Button(
          action: {
            viewStore.send(.showPrivacySheet)
          },
          label: {
            Text("Privacy")
              .font(.title3)
              .bold()
              .foregroundColor(.blue)
          }
        )
        .sheet(
          isPresented: viewStore.binding(
            get: {
              $0.showPrivacySheet
            }, send: { _ -> ViewAction in .showPrivacySheet })
        ) {
          // TermsAndPrivacyWebView(urlString: baseURL.appendingPathComponent("/privacy").absoluteString)
        }
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static let now = Date()

  static let user = User(
    id: UUID().uuidString, phoneNumber: "+79218821217", createdAt: now, updatedAt: now)
  static let access = AuthTokenResponse(accessToken: "fdsfdsafas", refreshToken: "sfasdfas")

  static var environment = AuthenticationEnvironment(
    authClient: .happyPath,
    userDefaults: .live(),
    mainQueue: .main.eraseToAnyScheduler()
  )

  static var store = Store(
    initialState: LoginState(),
    reducer: loginReducer,
    environment: environment
  )

  static var previews: some View {
    AuthenticationView(store: store)
  }
}

extension AuthenticationView {
  struct ViewState: Equatable {
    public var alert: AlertState<LoginAction>?
    public var authResponse: AuthResponse?
    public var isUserFirstNameEmpty = false
    public var isValidationCodeIsSend = false
    public var isLoginRequestInFlight = false
    public var isAuthorized: Bool = false
    public var showTermsSheet: Bool = false
    public var showPrivacySheet: Bool = false
  }

  enum ViewAction: Equatable {
    case alertDismissed
    case showTermsSheet
    case showPrivacySheet
    case sendPhoneNumberButtonTapped(String)
    case verificationRequest(String)
  }
}

extension LoginState {
  var view: AuthenticationView.ViewState {
    AuthenticationView.ViewState(
      alert: alert,
      authResponse: authResponse,
      isUserFirstNameEmpty: isUserFirstNameEmpty,
      isValidationCodeIsSend: isValidationCodeIsSend,
      isLoginRequestInFlight: isLoginRequestInFlight,
      isAuthorized: isAuthorized,
      showTermsSheet: showTermsSheet,
      showPrivacySheet: showPrivacySheet
    )
  }
}

extension LoginAction {
  static func view(_ localAction: AuthenticationView.ViewAction) -> Self {
    switch localAction {
    case .alertDismissed:
      return .alertDismissed
    case let .sendPhoneNumberButtonTapped(phoneNumber):
      return .sendPhoneNumberButtonTapped(phoneNumber)
    case let .verificationRequest(authResponse):
      return .verificationRequest(authResponse)
    case .showTermsSheet:
      return .showTermsSheet
    case .showPrivacySheet:
      return .showPrivacySheet
    }
  }
}
