import UIKit
import Combine
import SwiftUI
import Foundation

import ComposableArchitecture
import ComposableArchitectureHelpers
import KeychainClient
import SettingsView
import AddaSharedModels
import ImagePicker
import MyEventsView
import SettingsFeature
import AttachmentS3Client

public struct Profile: ReducerProtocol {

    public struct State: Equatable {

        public var alert: AlertState<Profile.Action>?
        public var isUploadingImage: Bool = false
        public var isImagePickerPresented = false
        public var inputImage: UIImage?
        public var moveToSettingsView = false
        public var moveToAuthView: Bool = false
        public var user: UserOutput = .withFirstName
        public var isUserHaveAvatarLink: Bool = false
        public var myEventsState = MyEvents.State()

        public var imagePickerState: ImagePickerReducer.State?
        public var imageURLs: [String] = []

        public var settingsState: Settings.State
        public var isSettingsNavigationActive: Bool = false

        public init(
            alert: AlertState<Profile.Action>? = nil,
            isUploadingImage: Bool = false,
            isImagePickerPresented: Bool = false,
            inputImage: UIImage? = nil,
            moveToSettingsView: Bool = false,
            moveToAuthView: Bool = false,
            user: UserOutput = .withFirstName,
            isUserHaveAvatarLink: Bool = false,
            myEventsState: MyEvents.State = MyEvents.State(),
            imagePickerState: ImagePickerReducer.State? = nil,
            imageURLs: [String] = [],
            isLoadingPage: Bool = false,
            canLoadMorePages: Bool = true,
            currentPage: Int = 1,
            settingsState: Settings.State = .init()
        ) {
            self.alert = alert
            self.isUploadingImage = isUploadingImage
            self.isImagePickerPresented = isImagePickerPresented
            self.inputImage = inputImage
            self.moveToSettingsView = moveToSettingsView
            self.moveToAuthView = moveToAuthView
            self.user = user
            self.isUserHaveAvatarLink = isUserHaveAvatarLink
            self.myEventsState = myEventsState
            self.settingsState = settingsState
            self.imagePickerState = imagePickerState
            self.imageURLs = imageURLs
            self.settingsState = settingsState
        }
    }

    public enum Action: Equatable {
        case onAppear
        case alertDismissed
        case isUploadingImage
        case isImagePicker(isPresented: Bool)
        case settingsView(isNavigate: Bool)
        case moveToAuthView

        case fetchMyData
        case uploadAvatar(_ image: UIImage)
        case updateUserName(String, String)
        case createAttachment(_ attachment: AttachmentInOutPut)

        case imageUploadResponse(TaskResult<String>)
        case userResponse(TaskResult<UserOutput>)
        case attacmentResponse(TaskResult<AttachmentInOutPut>)
        case attacmentsResponse(TaskResult<[AttachmentInOutPut]>)
        case myEvents(MyEvents.Action)
        case imagePicker(action: ImagePickerReducer.Action)

        case resetAuthData
        case settings(Settings.Action)
        case getUser
        case getUserAttachments
        case getUserEvents

    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.attachmentS3Client) var attachmentS3Client

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.settingsState, action: /Action.settings) {
          Settings()
        }

        Scope(state: \.myEventsState, action: /Action.myEvents) {
            MyEvents()
        }

        Reduce(self.core)
            .ifLet(\.imagePickerState, action: /Action.imagePicker) {
                ImagePickerReducer()
            }
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:

            do {
                state.user = try self.keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
            } catch {
                state.alert = .init(title: TextState("Missing you id! please login again!"))
                return .none
            }

            let id = state.user.id.hexString

            return .run { send in
                await send(.getUser)
                await send(.getUserAttachments)
                await send(.getUserEvents)
            }


        case .alertDismissed:
            state.alert = nil
            return .none

        case .isUploadingImage:
            return .none

        case let .settingsView(isMovie):
            state.isSettingsNavigationActive = isMovie
            return .none

        case .moveToAuthView:

            return .none

        case .fetchMyData:

            return .none

        case let .uploadAvatar(image):
            state.isUploadingImage = true

            return .none

        case let .updateUserName(firstName, lastName):
            state.user.fullName = firstName + " " + lastName
            let input = UserOutput.init(id: state.user.id, fullName: state.user.fullName!, role: .basic, language: .russian, attachments: nil, url: .empty)

            return .task {
                .userResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .authEngine(.users(.update(input: input))),
                            as: UserOutput.self,
                            decoder: .iso8601
                        )
                    }
                )
            }

        case let .createAttachment(attachment):

            let id = state.user.id.hexString

            return .task {
                .attacmentResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .authEngine(.users(.user(id: id, route: .attachments(.create(input: attachment))))),
                            as: AttachmentInOutPut.self,
                            decoder: .iso8601
                        )
                    }
                )
            }

            //    return environment.attachmentClient.updateUserImageURL(attachment, "")
            //      .receive(on: environment.mainQueue)
            //      .catchToEffect()
            //      .map(ProfileAction.attacmentResponse)

        case .resetAuthData:
//            AppUserDefaults.save(false, forKey: .isAuthorized)
//            KeychainService.save(codable: UserOutput?.none, for: .user)
//            KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
//            KeychainService.logout()
//            AppUserDefaults.erase()

            return .none

        case let .userResponse(.success(user)):
            state.user = user
            state.isUploadingImage = false
            if let attachments = user.attachments {
                state.imageURLs = attachments.filter { $0.type == .image }
                    .compactMap { $0.imageUrlString }

            }

            return .run { _ in
                do {
                    try await keychainClient.saveCodable(user, .user, build.identifier())
                }  catch {
                    print(#line, error)
                }
            }
        case let .userResponse(.failure(error)):
            state.isUploadingImage = false
            state.alert = .init(title: TextState(error.localizedDescription))
            return .none

        case let .attacmentResponse(.success(attachmentResponse)):

            state.isUploadingImage = false
            if let image = attachmentResponse.imageUrlString {
                state.imageURLs.insert(image, at: 0)
            }

            return .none

        case let .attacmentResponse(.failure(error)):
            state.isUploadingImage = false
            state.alert = .init(title: TextState("\(#line) \(error.localizedDescription)"))
            return .none

        case let .attacmentsResponse(.success(attachmentsResponse)):

            state.isUploadingImage = false
            let images = attachmentsResponse.compactMap({ $0.imageUrlString })
            state.imageURLs = images

            return .none

        case let .attacmentsResponse(.failure(error)):
            state.isUploadingImage = false
            state.alert = .init(title: TextState("\(#line) \(error.localizedDescription)"))
            return .none

        case .settings:
            return .none

        case let .imageUploadResponse(.success(imageURLString)):
            let id = state.user.id

            let attachmentInput = AttachmentInOutPut(type: .image, userId: id, imageUrlString: imageURLString)

            return .task {
                await .attacmentResponse(
                    TaskResult {
                       try await apiClient.request(
                        for: .authEngine(.users(.user(id: id.hexString, route: .attachments(.create(input: attachmentInput))))),
                        as: AttachmentInOutPut.self,
                        decoder: .iso8601
                       )
                    }
                )
            }

        case let .imageUploadResponse(.failure(error)):
            state.isUploadingImage = false
            // handle alert
            return .none

        case .isImagePicker(isPresented: let isPresented):
            state.imagePickerState = isPresented ? ImagePickerReducer.State(showingImagePicker: true) : nil
            return .none

        case let .imagePicker(.picked(result: .success(image))):
            state.isUploadingImage = true
            state.imagePickerState = nil

            let id = state.user.id.hexString

            return .task {
                await .imageUploadResponse(
                    TaskResult {
                        try await attachmentS3Client.uploadImageToS3(image, nil, id)
                    }
                )
            }

        case .imagePicker(_):
            return .none
            
        case .myEvents:
            return .none

        case .getUser:
            let id = state.user.id.hexString

            return .task {
                .userResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .authEngine(.users(.user(id: id, route: .find))),
                            as: UserOutput.self,
                            decoder: .iso8601
                        )
                    }
                )
            }

        case .getUserAttachments:
            let id = state.user.id.hexString
            return .task {
                .attacmentsResponse(
                    await TaskResult {
                        try await apiClient.request(
                            for: .authEngine(.users(.user(id: id, route: .attachments(.findWithOwnerId)))),
                            as: [AttachmentInOutPut].self,
                            decoder: .iso8601
                        )
                    }
                )
            }
        case .getUserEvents:
                return .none
        }
    }
}

//public let profileReducer = Reducer<
//    ProfileState,
//    ProfileAction,
//    ProfileEnvironment>.combine(
//        myEventsReducer.pullback(
//            state: \.myEventsState,
//            action: /ProfileAction.myEvents,
//            environment: { _ in MyEventsEnvironment.live }
//        ),
//        Reducer {state, action, environment in
//
//
//        })
//
//    .debug()
//    .presenting(
//        settingsReducer,
//        state: .keyPath(\.settingsState),
//        id: .notNil(),
//        action: /ProfileAction.settings,
//        environment: { _ in SettingsEnvironment.live }
//    )
//    .presenting(
//        imagePickerReducer,
//        state: .keyPath(\.imagePickerState),
//        id: .notNil(),
//        action: /ProfileAction.imagePicker,
//        environment: { _ in ImagePickerEnvironment.live }
//    )
