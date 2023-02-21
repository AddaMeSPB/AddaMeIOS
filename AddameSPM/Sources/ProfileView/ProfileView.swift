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
                    .padding(.bottom, 100)
                  },
                  image: {
                    Image(uiImage: $0).resizable()
                  }
                )
                .scaledToFit()
                .frame(alignment: .center)
                .listRowBackground(Color(.secondarySystemBackground))
              }
          }
          .aspectRatio(5 / 4, contentMode: .fill)
          .overlay(
            ProfileImageOverlay(store: self.store),
            alignment: .bottomTrailing
          )
          .edgesIgnoringSafeArea(.horizontal)
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
        .padding(.top, 90)
      }
      .navigationBarTitle("Profile", displayMode: .inline)
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
//    .sheet(
//      store.scope(
//        state: \.imagePickerState,
//        action: Profile.Action.imagePicker
//      ),
//      mapState: replayNonNil(),
//      onDismiss: {
//         ViewStore(store.stateless)
//           .send(.isImagePicker(isPresented: false))
//      },
//      content: ImagePicker.init(store:)
//    )
//    .background(
//      NavigationLinkWithStore(
//        store.scope(state: \.settingsState, action: Profile.Action.settings),
//        mapState: replayNonNil(),
//        onDeactivate: { ViewStore(store.stateless)
//          .send(.settingsView(isNavigation: false))
//        },
//        destination: SettingsView.init(store:)
//      )
//    )
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
            ZStack {
                if viewStore.state.isUploadingImage {
                    withAnimation {
                        HUDProgressView(
                            placeHolder: "Image uploading...",
                            show: viewStore.binding(
                                get: { $0.isUploadingImage },
                                send: { _ in .isUploadingImage }
                            )
                        )
                    }
                }

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewStore.send(.isImagePicker(isPresented: true))
                        }, label: {
                            Image(systemName: "camera")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.backgroundColor(for: colorScheme))
                                .frame(width: 40, height: 40)
                        })
                        .imageScale(.large)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(
                            Circle().strokeBorder(Color.backgroundColor(for: colorScheme), lineWidth: 1.25)
                        )
                        .padding()
                    }

                    Spacer()

                    VStack {
                        Text(viewStore.user.fullName ?? "unknown")
                            .foregroundColor(Color.black)
                            .font(.title).bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.bottom, -5)
                        Text(viewStore.user.phoneNumber ?? "unknown" )
                            .foregroundColor(Color.black)
                            .font(.body)
                            .frame(maxWidth: .infinity)

                        Spacer()
                        //            HStack {
                        //              Text("Something Cool:")
                        //                .font(.body).bold()
                        //                .frame(maxWidth: .infinity)
                        //                .padding()
                        //
                        //              Text("Total events: 99")
                        //                .font(.body).bold()
                        //                .frame(maxWidth: .infinity)
                        //                .padding()
                        //            }
                    }
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                    )
                    .padding(30)
                    .padding(.bottom, -100)
                }
            }
        }
    }
}

