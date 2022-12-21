import Combine
import ComposableArchitecture
import KeychainClient
import PhoneNumberKit
import AddaSharedModels
import SwiftUI
import UserDefaultsClient
import Build
import APIClient
import RegisterFormFeature
import FoundationExtension
import SettingsFeature

public enum VerificationCodeCanceable {}

public struct Login: ReducerProtocol {
    public struct State: Equatable {

      public init() {}

      public static func == (lhs: State, rhs: State) -> Bool {
        return lhs.isAuthorized == rhs.isAuthorized
      }

      public var alert: AlertState<Action>?

      public var niceName = ""
      public var email: String = ""
      public var code: String = ""

      public var emailLoginInput: EmailLoginInput?
      public var emailLoginOutput: EmailLoginOutput?
      public var isValidationCodeIsSend = false
      public var isLoginRequestInFlight = false
      public var isAuthorized: Bool = false
      public var isUserFirstNameEmpty: Bool = true
      public var deviceCheckData: Data?
      public var isEmailValidated: Bool = false

      public var registerState: RegisterFormReducer.State?
      public var isSheetRegisterPresented: Bool { self.registerState != nil }

      /// Move to SettingFeature
      public var termsAndPrivacy: TermsAndPrivacy.State?
      public var isTermsOrPrivacySheetOpen: TermsOrPrivacy = .nill
      public  var isSheetTermsAndPrivacyPresented: Bool { self.termsAndPrivacy != nil }
        
    }

    public enum TermsOrPrivacy {
        case nill, terms, privacy
    }

    public enum Action: Equatable {
      case onAppear
      case alertDismissed
      case termsPrivacySheet(isPresented: TermsOrPrivacy)
      case sendEmailButtonTapped
      case niceNameTextChanged(String)
      case emailTextChanged(String)
      case codeChanged(String)
      case loninResponse(TaskResult<EmailLoginOutput>)
      case verificationResponse(TaskResult<SuccessfulLoginResponse>)

      case termsAndPrivacy(TermsAndPrivacy.Action)
      case isSheetTermsAndPrivacy(isPresented: Bool)
      case register(RegisterFormReducer.Action)
      case isSheetRegister(isPresented: Bool)
      case moveToTableView
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build
    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        self.core
    }

    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {

            case .onAppear:
                state.isAuthorized = userDefaults.boolForKey(UserDefaultKey.isAuthorized.rawValue)
                state.isUserFirstNameEmpty = userDefaults.boolForKey(UserDefaultKey.isUserFirstNameEmpty.rawValue)

                let isAuthorized = userDefaults.boolForKey(UserDefaultKey.isAuthorized.rawValue) == true
                let isAskPermissionCompleted = userDefaults.boolForKey(UserDefaultKey.isAskPermissionCompleted.rawValue) == true

                if isAuthorized {
                    if !isAskPermissionCompleted {
                        state.registerState = .init()
                        return .none
                    }
                }

                return .none

            case .alertDismissed:
                state.alert = nil
                return .none

            case .niceNameTextChanged(let name):
                state.niceName = name

                return .none

            case .emailTextChanged(let email):
                state.email = email

                guard email.isEmailValid else {
                    state.isEmailValidated = false
                    return .none
                }

                state.isEmailValidated = true
                return .none

            case .sendEmailButtonTapped:
                state.isLoginRequestInFlight = true

                state.isEmailValidated = true
                let emailLoginInput = EmailLoginInput(email: state.email.lowercased())
                state.emailLoginInput = emailLoginInput

                return .task {
                    return .loninResponse(
                        await TaskResult {
                            try await apiClient.decodedResponse(
                                for: .authEngine(.authentication(.loginViaEmail(emailLoginInput))),
                                as: EmailLoginOutput.self
                            ).value
                        }
                    )
                }

            case let .codeChanged(code):

                guard let emailLoginOutput = state.emailLoginOutput else {
                    return .none
                }

                state.code = code

                if code.count == 6 {

                    state.isLoginRequestInFlight = true

                    let input = VerifyEmailInput(
                        niceName: state.niceName,
                        email: emailLoginOutput.email,
                        attemptId: emailLoginOutput.attemptId,
                        code: code
                    )

                    return .task {
                        .verificationResponse(
                            await TaskResult {
                                try await apiClient.decodedResponse(
                                    for: .authEngine(.authentication(.verifyEmail(input))),
                                    as: SuccessfulLoginResponse.self
                                ).value
                            }
                        )
                    }
                    .cancellable(id: VerificationCodeCanceable.self)
                }

                return .none

            case let .loninResponse(.success(emailLoginOutput)):
                state.isLoginRequestInFlight = false
                state.isValidationCodeIsSend = true
                state.emailLoginOutput = emailLoginOutput

                return .none

            case .loninResponse(.failure(let error)):
                state.isLoginRequestInFlight = false
                state.isValidationCodeIsSend = false
                print(#line, self, error.localizedDescription)
                return .none

            case let .verificationResponse(.success(loginRes)):

                if loginRes.user == nil || loginRes.access == nil {
                    return .none
                }

                state.isLoginRequestInFlight = false

                return .run(priority: .background) { _ in

                    await withThrowingTaskGroup(of: Void.self) { group in

                        group.addTask {
                            await userDefaults.setBool(
                                 true,
                                 UserDefaultKey.isAuthorized.rawValue
                            )

                            await self.userDefaults.setBool(
                                loginRes.user?.fullName == nil ? false : true,
                                UserDefaultKey.isUserFirstNameEmpty.rawValue
                            )
                        }

                        group.addTask {
                            try await keychainClient.saveCodable(loginRes.user, .user, build.identifier())
                            try await keychainClient.saveCodable(loginRes.access, .token, build.identifier())
                        }
                    }
                }

            case .verificationResponse(.failure(_)):
                state.alert = .init(title: TextState("Please try again!") )
                // send this for logs .init(title: TextState(error.description))
                state.isLoginRequestInFlight = false

                return .none

            case .termsPrivacySheet(let actiontp):
                switch actiontp {
                case .nill:
                    state.termsAndPrivacy = nil
                    return .none

                case .terms:
                    state.termsAndPrivacy = .init(wbModel: .init(link: "https://addame.com/terms"))
                    return .none

                case .privacy:
                    state.termsAndPrivacy = .init(wbModel: .init(link: "https://addame.com/privacy"))
                    return .none
                }

            case .isSheetTermsAndPrivacy(isPresented: true):
                return .none

            case .isSheetTermsAndPrivacy(isPresented: false):
                return .run { send in
                    await send(.termsPrivacySheet(isPresented: .nill))
                }

            case .termsAndPrivacy(.leaveCurentPageButtonClick):
                state.termsAndPrivacy = nil
                return .none

            case .termsAndPrivacy:
                return .none

            case .register(.moveToLoginView):
                state.registerState = nil
                return .run { send in
                    try await self.mainQueue.sleep(for: .seconds(0.3))
                    await send(.moveToTableView)
                }

            case .register:
                return .none

            case .isSheetRegister(isPresented: let presented):
                if presented {
                    state.registerState = .init()
                } else {
                    state.registerState = nil
                }
                return .none
            case .moveToTableView:
                return .none
            }
        }
        // this part move to SettinsFeature
        .ifLet(\.termsAndPrivacy, action: /Login.Action.termsAndPrivacy) {
            TermsAndPrivacy()
        }
        .ifLet(\.registerState, action: /Login.Action.register) {
            RegisterFormReducer()
        }
    }
}
