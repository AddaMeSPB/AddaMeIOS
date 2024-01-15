//
//  AuthenticationView.swift
//
//
//  Created by Saroar Khandoker on 07.04.2021.
//

import ComposableArchitecture
import PhoneNumberKit
import AddaSharedModels
import SwiftUI
import SwiftUIHelpers
import RegisterFormFeature
import SettingsFeature
import SwiftUIExtension

public struct AuthenticationView: View {

    let store: StoreOf<Login>
    @ObservedObject var viewStore: ViewStore<ViewState, Login.Action>

    public init(store: Store<Login.State, Login.Action>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: ViewState.init)
    }

    public var body: some View {

        ZStack(alignment: .top) {

            VStack {

                Text("Adda")
                    .font(Font.system(size: 100, weight: .heavy, design: .serif))
                    .foregroundColor(.red)
                    .padding(.top, 30)

                if !viewStore.isValidationCodeIsSend {
                    Text("Register Or Login")
                        .font(Font.system(size: 33, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                }

                if viewStore.isValidationCodeIsSend {
                    Text("Verification Code")
                        .font(Font.system(size: 33, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                }

                ZStack {
                    if !viewStore.isValidationCodeIsSend {
                        inputEmailTextView().disabled(viewStore.isLoginRequestInFlight)
                    }

                    if viewStore.isValidationCodeIsSend {
                        HStack {
                            TextField(
                                "000000",
                                text: viewStore.binding(
                                    get: \.code,
                                    send: Login.Action.codeChanged
                                )
                                .removeDuplicates()
                            )
                            .keyboardType(.numberPad)
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
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))

                if !viewStore.isValidationCodeIsSend  {
                    Button(
                        action: {
                            viewStore.send(.sendEmailButtonTapped)
                        },
                        label: {
                            HStack {
                                if !viewStore.isLoginRequestInFlight {
                                    Image(systemName: "arrow.right")
                                        .font(.largeTitle)
                                        .frame(maxWidth:.infinity)
                                        .padding()
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.hex(0x5E00CF)))
                                        .padding()
                                    // color have to be black
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    )

                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)

                    .disabled(
                        (!viewStore.isEmailValidated
                        || viewStore.isLoginRequestInFlight)
                        && self.viewStore.niceName.isEmpty
                    )
                    .foregroundColor(
                        self.viewStore.isEmailValidated
                        && !self.viewStore.niceName.isEmpty ? Color.red : Color.white
                    )
                    .background(
                        self.viewStore.isEmailValidated
                        && !self.viewStore.niceName.isEmpty ? Color.yellow : Color.gray
                    )
                    .buttonStyle(.plain)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)

                }

                if viewStore.isValidationCodeIsSend {
                    Text("*** Didn't get email? Please check your mail spam folder!")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(Font.system(size: 16, weight: .medium, design: .rounded))
                        .padding(.horizontal, 20)
                        .foregroundColor(.red)
                }

                if !viewStore.isValidationCodeIsSend {
                    termsAndPrivacyView()
                }

                Spacer()
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
//        .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
        .onTapGesture {
            hideKeyboard()
        }
        /// Move to SettingFeature
        .sheet(
            isPresented: viewStore.binding(
                get: \.isSheetTermsAndPrivacyPresented,
                send: Login.Action.isSheetTermsAndPrivacy(isPresented:)
            )
        ) {
            IfLetStore(
                self.store.scope(state: \.termsAndPrivacy, action: Login.Action.termsAndPrivacy),
                then: TermsAndPrivacyWebView.init(store:)
            )
        }
        .fullScreenCover(
            isPresented: viewStore.binding(
                get: \.isSheetRegisterPresented,
                send: Login.Action.isSheetRegister(isPresented:)
            )
        ) {
            IfLetStore(
                self.store.scope(state: \.registerState, action: Login.Action.register),
                then: RegisterFormView.init(store:)
            )
        }
    }

    private func inputEmailTextView() -> some View {
        VStack {
            TextField(
                "* Your nice Name goes here",
                text: viewStore.binding(get: \.niceName, send: Login.Action.niceNameTextChanged)
            )
            .keyboardType(.default)
            .autocorrectionDisabled()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
            .textCase(.lowercase)
            .autocapitalization(.none)
            .padding(.leading, 30)
            .padding(.bottom, -10)
            .disabled(viewStore.isLoginRequestInFlight)
            .ignoresSafeArea(.keyboard, edges: .bottom)

            Divider()

            TextField(
                "* Email",
                text: viewStore.binding(get: \.email, send: Login.Action.emailTextChanged)
            )
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
            .textCase(.lowercase)
            .autocapitalization(.none)
            .padding(.leading, 30)
            .padding(.top, -10)
            .disabled(viewStore.isLoginRequestInFlight && viewStore.isEmailValidated)
            .ignoresSafeArea(.keyboard, edges: .bottom)

        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.3), lineWidth: 0.6)
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
    }

    private func inputCodeTextView() -> some View {
        VStack {
            HStack {
                TextField(
                    "000000",
                    text: viewStore.binding(
                        get: \.code,
                        send: Login.Action.codeChanged
                    )
                    .removeDuplicates()
                )
                .keyboardType(.numberPad)
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

            Text("*** Didn't Get My Email? PLease Check Your mail Spam Folder!")
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(Font.system(size: 16, weight: .medium, design: .rounded))
                .padding()
                .foregroundColor(.red)

        }
//        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)

    }

    private func termsAndPrivacyView() -> some View {
        VStack {
            Text("Check our terms and privacy")
                .font(.body)
                .bold()
                .foregroundColor(.green)
                .padding()

            HStack {
                Button(
                    action: {
                        viewStore.send(.termsPrivacySheet(isPresented: .terms))
                    },
                    label: {
                        Text("Terms")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.green)
                    }
                )

                Text("&")
                    .font(.title3)
                    .bold()
                    .padding([.leading, .trailing], 10)
                    .foregroundColor(.red)

                Button(
                    action: {
                        viewStore.send(.termsPrivacySheet(isPresented: .privacy))
                    },
                    label: {
                        Text("Privacy")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.green)
                    }
                )

            }
        }
    }
}

//#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
    static var store = Store(initialState: Login.State()) {
        Login()
    }

    static var previews: some View {
//        Preview {
            AuthenticationView(store: store)
//        }
    }
}
//#endif

