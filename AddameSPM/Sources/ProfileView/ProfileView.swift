import SwiftUI
import AsyncImageLoder
import ComposableArchitecture
import AddaSharedModels
import SwiftUIExtension
import ImagePicker
import MyEventsView
import SwiftUIHelpers
import SettingsFeature

extension String {
    var url: URL? { return URL(string: self) }
}

extension ProfileView {
    public struct ViewState: Equatable {
        public init(state: Profile.State) {
            self.alert = state.alert
            self.isUploadingImage = state.isUploadingImage
            self.moveToSettingsView = state.moveToSettingsView
            self.user = state.user
            self.isUserHaveAvatarLink = state.isUserHaveAvatarLink
            self.myEventsState = state.myEventsState
            self.imagePickerState = state.imagePickerState
            self.imageURLs = state.imageURLs
            self.settingsState = state.settingsState
            self.isSettingsNavigationActive = state.isSettingsNavigationActive
        }

        public var alert: AlertState<Profile.Action>?
        public var isUploadingImage: Bool

        public var moveToSettingsView: Bool
        public var user: UserOutput
        public var isUserHaveAvatarLink: Bool
        public var myEventsState: MyEvents.State
        public var imagePickerState: ImagePickerReducer.State?
        public var imageURLs: [String]
        public var settingsState: Settings.State
        public var isSettingsNavigationActive: Bool

        var isImagePickerPresented: Bool { imagePickerState != nil }
    }

    public enum ViewAction: Equatable {
        case alertDismissed
        case isUploadingImage
        case isImagePicker(isPresented: Bool)
        case moveToSettingsView
        case settingsView(isNavigate: Bool)

        case fetchMyData
        case uploadAvatar(_ image: UIImage)
        case updateUserName(String, String)
        case createAttachment(_ attachment: AttachmentInOutPut)

        case userResponse(TaskResult<UserOutput>)
        case imagePicker(action: ImagePickerReducer.Action)

        case resetAuthData
        //    case settings(Settings.Action)
    }

}

public struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<Profile>

    public init(store: StoreOf<Profile>) {
        self.store = store
    }

    @State var index = 0

    public var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: Profile.Action.view) { viewStore in

            ScrollView(.vertical) {

                if !viewStore.state.imageURLs.isEmpty {
                    PagingView(
                        index: $index.animation(),
                        maxIndex: viewStore.state.imageURLs.count - 1
                    ) {
                        ForEach(viewStore.state.imageURLs, id: \.self) { url in
                            AsyncImage(
                                url: URL(string: url)!,
                                placeholder: {
                                    HUDProgressView(
                                        placeHolder: "Image is loading...",
                                        show: viewStore.binding(
                                            get: { $0.isUploadingImage },
                                            send: .isUploadingImage
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                },
                                image: {
                                    Image(uiImage: $0)
                                        .resizable()

                                }
                            )
                            .scaledToFill()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [.white.opacity(0), .black.opacity(0.3)]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .aspectRatio(5 / 4, contentMode: .fill)
                    .overlay(
                        ProfileImageOverlay(store: self.store),
                        alignment: .bottomTrailing
                    )
                    .cornerRadius(radius: 30, corners: [.bottomLeft, .bottomRight])

                } else {
                    Text("Upload your avatar!")
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .foregroundColor(
                            Color.backgroundColor(for: self.colorScheme)
                        )
                        .background(Color.yellow)
                        .overlay(
                            ProfileImageOverlay(store: self.store),
                            alignment: .bottomTrailing
                        )
                }

                VStack {
                    MyEventsListView(store: self.store.scope(state: \.myEventsState, action: Profile.Action.myEvents))
                }
                .padding(.top, 20)
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.settingsView(isNavigate: true))
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(
                                Color.backgroundColor(for: self.colorScheme)
                            )
                    }
                }
            }
            .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
            .background(
                NavigationLink(
                    destination: SettingsView(store: self.store.scope(
                        state: \.settingsState,
                        action: Profile.Action.settings
                    )
                    ),
                    isActive: viewStore.binding(
                        get: \.isSettingsNavigationActive,
                        send:  { .settingsView(isNavigate: $0) }
                    )
                ) {}
            )
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isImagePickerPresented,
                    send: { .isImagePicker(isPresented: $0) }
                )
            ) {
                IfLetStore(
                    self.store.scope(
                        state: \.imagePickerState,
                        action: Profile.Action.imagePicker
                    )
                ) {
                    ImagePickerView.init(store: $0)
                } else: {
                    ProgressView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

public struct ProfileImageOverlay: View {
    @Environment(\.colorScheme) var colorScheme

    let store: StoreOf<Profile>

    public init(store: StoreOf<Profile>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewStore.send(.isImagePicker(isPresented: true))
                    }, label: {
                        Image(systemName: "camera")
                            .foregroundColor(Color.backgroundColor(for: colorScheme))
                    })
                    .imageScale(.medium)
                    .frame(width: 35, height: 35, alignment: .center)
                    .background(
                        Circle().strokeBorder(Color.backgroundColor(for: colorScheme), lineWidth: 1.25)
                    )
                    .padding()
                    .padding(.top, 25)

                }

                Spacer()

                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(viewStore.user.fullName ?? "unknown")
                            .foregroundColor(Color.white)
                            .font(.title2).fontWeight(.medium)
                            .padding(.bottom, -5)

                        Text(viewStore.user.phoneNumber ?? "unknown" )
                            .foregroundColor(Color.white)
                            .font(.body)
                            .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(
                store: .init(
                    initialState: Profile.State.profileStateWithUserWithAvatar,
                    reducer: Profile()
                )
            )
        }
    }
}
