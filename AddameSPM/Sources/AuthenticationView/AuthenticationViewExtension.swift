import ComposableArchitecture
import AddaSharedModels
import SwiftUI
import RegisterFormFeature
import SettingsFeature

extension AuthenticationView {
    struct ViewState: Equatable {
        public init(state: Login.State) {
            self.niceName = state.niceName
            self.email = state.email
            self.code = state.code
            self.isLoginRequestInFlight = state.isLoginRequestInFlight
            self.isEmailValidated = state.isEmailValidated
            self.isValidationCodeIsSend = state.isValidationCodeIsSend
            self.isTermsOrPrivacySheetOpen = state.isTermsOrPrivacySheetOpen
            self.isSheetTermsAndPrivacyPresented = state.isSheetTermsAndPrivacyPresented
            self.isSheetRegisterPresented = state.registerState != nil
        }

        public var niceName: String
        public var email: String
        public var code: String
        public var isValidationCodeIsSend: Bool
        public var isEmailValidated: Bool
        public var isLoginRequestInFlight: Bool
        public var isTermsOrPrivacySheetOpen: Login.TermsOrPrivacy
        public var isSheetTermsAndPrivacyPresented: Bool
        public var isSheetRegisterPresented: Bool
    }

    enum ViewAction: Equatable {
        case onAppear
        case loninResponse(TaskResult<EmailLoginOutput>)
        case verificationResponse(TaskResult<SuccessfulLoginResponse>)
        case alertDismissed
        case showTermsSheet
        case showPrivacySheet
        case sendEmailButtonTapped
        case niceNameTextChanged(String)
        case emailTextChanged(String)
        case codeChanged(String)
        case termsAndPrivacy(TermsAndPrivacy.Action)
        case termsPrivacySheet(isPresented: Login.TermsOrPrivacy)
        case isSheetTermsAndPrivacy(isPresented: Bool)
        case register(RegisterFormReducer.Action)
        case isSheetRegister(isPresented: Bool)
        case moveToTableView

        init(action: Login.Action) {
            switch action {
            case .alertDismissed:
                self = .alertDismissed
            case .sendEmailButtonTapped:
                self = .sendEmailButtonTapped
            case let .codeChanged(authResponse):
                self = .codeChanged(authResponse)
            case .onAppear:
                self = .onAppear
            case .loninResponse(let response):
                self = .loninResponse(response)
            case .verificationResponse(let res):
                self = .verificationResponse(res)
            case .termsAndPrivacy(let action):
                self = .termsAndPrivacy(action)
            case .termsPrivacySheet(isPresented: let isPresented):
                self = .termsPrivacySheet(isPresented: isPresented)
            case .isSheetTermsAndPrivacy(isPresented: let isPresented):
                self = .isSheetTermsAndPrivacy(isPresented: isPresented)
            case let .register(reg):
                self = .register(reg)
            case let .isSheetRegister(presented):
                self = .isSheetRegister(isPresented: presented)
            case let .niceNameTextChanged(text):
                self = .niceNameTextChanged(text)
            case let .emailTextChanged(text):
                self = .emailTextChanged(text)
            case .moveToTableView:
                self = .moveToTableView
            }
        }
    }
}
