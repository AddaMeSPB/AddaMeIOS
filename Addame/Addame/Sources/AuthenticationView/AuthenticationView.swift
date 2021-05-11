//
//  SwiftUIView.swift
//  
//
//  Created by Saroar Khandoker on 07.04.2021.
//

import SwiftUI
import ComposableArchitecture
import PhoneNumberKit
import SharedModels
import AuthClient

public struct PhoneNumberTextFieldView: UIViewRepresentable, Equatable {
  public static func == (lhs: PhoneNumberTextFieldView, rhs: PhoneNumberTextFieldView) -> Bool {
    return lhs.isValid == rhs.isValid && lhs.phoneNumber == rhs.phoneNumber
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  @Binding var phoneNumber: String
  @Binding var isValid: Bool
  
  let phoneTextField = PhoneNumberTextField()
  
  public func makeUIView(context: Context) -> PhoneNumberTextField {
    phoneTextField.withExamplePlaceholder = true
    phoneTextField.withFlag = true
    phoneTextField.withPrefix = true
    phoneTextField.withExamplePlaceholder = true
    //phoneTextField.placeholder = "Enter phone number"
    phoneTextField.becomeFirstResponder()
    phoneTextField.addTarget(context.coordinator, action: #selector(Coordinator.onTextUpdate), for: .editingChanged)
    return phoneTextField
  }
  
  public func getCurrentText() {
    self.phoneNumber = phoneTextField.text!
  }
  
  public func updateUIView(_ view: PhoneNumberTextField, context: Context) {}
  
  public class Coordinator: NSObject, UITextFieldDelegate {
    
    var control: PhoneNumberTextFieldView
    
    init(_ control: PhoneNumberTextFieldView) {
      self.control = control
    }
    
    @objc func onTextUpdate(textField: UITextField) {
      control.isValid = self.control.phoneTextField.isValidNumber
    }
    
  }
}

public struct AuthenticationView: View {
  
  private var baseURL: URL { URL(string:  "http://0.0.0.0:8080/v1/")! } // load from info plist
  @State private var phoneField: PhoneNumberTextFieldView?
  @State private var isValidPhoneNumber: Bool = false
  @State private var phoneNumber: String = String.empty
  
  let store: Store<LoginState, LoginAction>
  
  public init(store: Store<LoginState, LoginAction>) {
    self.store = store
  }
  
  @ViewBuilder fileprivate func inputMobileNumberTextView(_ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>) -> some View {
    HStack {

      phoneField.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
        .keyboardType(.phonePad)
        .padding(.leading)
      
      Button(action: {
        self.phoneField?.getCurrentText()
        viewStore.send(.sendPhoneNumberButtonTapped(self.phoneNumber))
      }, label: {
        Text("GO")
          .font(.headline)
          .bold()
          .padding()
      })
      .disabled(!self.isValidPhoneNumber)
      .foregroundColor(self.isValidPhoneNumber ? Color.black : Color.white )
      .background(
        self.isValidPhoneNumber ? Color.yellow : Color.gray
      )
      .cornerRadius(50)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 30)
        .stroke(Color.black.opacity(0.1), lineWidth: 0.6)
        .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.06563035103)))
    )
    .onAppear {
      self.phoneField = PhoneNumberTextFieldView(
        phoneNumber: self.$phoneNumber,
        isValid: $isValidPhoneNumber
      )
    }
  }
  
  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: LoginAction.view )) { viewStore  in
      ZStack {
        if viewStore.isLoginRequestInFlight {
          withAnimation {
            Text("Lodaing......")
          }
        }
        
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
            }
            
            if viewStore.isValidationCodeIsSend {
              inputValidationCodeTextView(viewStore)
            }
            
          }
          .padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
          .padding(.bottom, 20)
          .padding(.leading, 10)
          .padding(.trailing, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
          
          if !viewStore.isValidationCodeIsSend {
            termsAndPrivacyView(viewStore)
          }
          
          Spacer()
        }
        
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
      
    }
  }
  
  fileprivate func inputValidationCodeTextView(_ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>) -> some View {
    return VStack {
      HStack {
        TextField(
          "__ __ __ __ __ __",
          text: viewStore.binding(get: { $0.authResponse?.code ?? "" }, send: ViewAction.verificationRequest )
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
          .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.06563035103)))
      )
    }
  }
  
  fileprivate func termsAndPrivacyView(_ viewStore: ViewStore<AuthenticationView.ViewState, AuthenticationView.ViewAction>) -> some View {
    VStack {
      Text("Check our terms and privacy")
        .font(.body)
        .bold()
        .foregroundColor(.blue)
        .padding()
      
      HStack {
        Button(action: {
          viewStore.send(.showTermsSheet)
        }, label: {
          Text("Terms")
            .font(.title3)
            .bold()
            .foregroundColor(.blue)
        })
        .sheet(
          isPresented: viewStore.binding(get: { $0.showTermsSheet }, send: { _ -> ViewAction in
            .showTermsSheet
          })
        ) {
          TermsAndPrivacyWebView(urlString: baseURL.appendingPathComponent("/terms").absoluteString )
        }
        
        Text("&")
          .font(.title3)
          .bold()
          .padding([.leading, .trailing], 10)
        
        Button(action: {
          viewStore.send(.showPrivacySheet)
        }, label: {
          Text("Privacy")
            .font(.title3)
            .bold()
            .foregroundColor(.blue)
        })
        .sheet(
          isPresented: viewStore.binding(get: { $0.showPrivacySheet
          }, send: { _ -> ViewAction in .showPrivacySheet})
        ) {
          TermsAndPrivacyWebView(urlString: baseURL.appendingPathComponent("/privacy").absoluteString )
        }
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  
  static let now = Date()
  
  static let user = User(id: UUID.init().uuidString, phoneNumber: "+79218821217", createdAt: now, updatedAt: now)
  static let access = AuthTokenResponse(accessToken: "fdsfdsafas", refreshToken: "sfasdfas")
  
  static var environment = AuthenticationEnvironment(
    authClient: .happyPath,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
  )
  
  static var store = Store(
    initialState: LoginState(),
    reducer: loginReducer,
    environment: environment)
  
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
      alert: self.alert,
      authResponse: self.authResponse,
      isUserFirstNameEmpty: self.isUserFirstNameEmpty,
      isValidationCodeIsSend: self.isValidationCodeIsSend,
      isLoginRequestInFlight: self.isLoginRequestInFlight,
      isAuthorized: self.isAuthorized,
      showTermsSheet: self.showTermsSheet,
      showPrivacySheet: self.showPrivacySheet
    )
  }
}

extension LoginAction {
  static func view(_ localAction: AuthenticationView.ViewAction) -> Self {
    switch localAction {
    case .alertDismissed:
      return .alertDismissed
    case .sendPhoneNumberButtonTapped(let phoneNumber):
      return .sendPhoneNumberButtonTapped(phoneNumber)
    case .verificationRequest(let authResponse):
      return .verificationRequest(authResponse)
    case .showTermsSheet:
      return .showTermsSheet
    case .showPrivacySheet:
      return .showPrivacySheet
    }
  }
}
