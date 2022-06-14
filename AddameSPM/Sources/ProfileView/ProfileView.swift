import AsyncImageLoder
import AuthenticationView
import ComposableArchitecture
import ComposablePresentation
import HTTPRequestKit
import KeychainService
import SettingsView
import SharedModels
import SwiftUI
import SwiftUIExtension
import UserClient
import ImagePicker

extension ProfileView {

  public struct ViewState: Equatable {
    public var alert: AlertState<ProfileAction>?
    public var isUploadingImage: Bool = false
    public var isImagePickerPresented = false
    public var inputImage: UIImage?
    public var moveToSettingsView = false
    public var moveToAuthView: Bool = false
    public var user = User.draff
    public var isUserHaveAvatarLink: Bool = false
    public var myEvents: IdentifiedArrayOf<EventResponse.Item> = []
    public var isLoadingPage = false
    public var canLoadMorePages = true
    public var currentPage = 1
    public var index = 0
    public var settingsState: SettingsState?
    public var imagePickerState: ImagePickerState?
    public var imageURLs: [String] = []
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case isUploadingImage
    case isImagePicker(isPresented: Bool)
    case moveToSettingsView
    case settingsView(isNavigation: Bool)

    case fetchMyData
    case uploadAvatar(_ image: UIImage)
    case updateUserName(String, String)
    case createAttachment(_ attachment: Attachment)

    case userResponse(Result<User, HTTPRequest.HRError>)
    case attacmentResponse(Result<Attachment, HTTPRequest.HRError>)
    case event(index: EventResponse.Item.ID, action: MyEventAction)
    case settings(SettingsAction)
    case imagePicker(action: ImagePickerAction)

    case resetAuthData
  }

}

public struct ProfileView: View {
  @Environment(\.colorScheme) var colorScheme
  let store: Store<ProfileState, ProfileAction>

  public init(store: Store<ProfileState, ProfileAction>) {
    self.store = store
  }

  @State var index = 0

  @ViewBuilder
  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: ProfileAction.view
      )
    ) { viewStore in

      ScrollView(.vertical) {

        if !viewStore.state.imageURLs.isEmpty {
          PagingView(
            index: $index.animation(),
            maxIndex: viewStore.state.imageURLs.count - 1
          ) {
              ForEach(viewStore.state.imageURLs, id: \.self) { url in
                AsyncImage(
                  urlString: url,
                  placeholder: {
                    HUDProgressView(
                      placeHolder: "Image is loading...",
                      show: viewStore.binding(
                        get: { $0.isUploadingImage },
                        send: { _ in ViewAction.isUploadingImage }
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
          MyEventListView(store: self.store)
        }
        .padding(.top, 90)
      }
      .onAppear { viewStore.send(.onAppear) }
      .navigationBarTitle("Profile", displayMode: .inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewStore.send(.settingsView(isNavigation: true))
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
    }
    .onAppear {
      ViewStore(store.stateless).send(.onAppear)
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .sheet(
      store.scope(
        state: \.imagePickerState,
        action: ProfileAction.imagePicker
      ),
      mapState: replayNonNil(),
      onDismiss: {
         ViewStore(store.stateless)
           .send(.isImagePicker(isPresented: false))
      },
      content: ImagePicker.init(store:)
    )
    .background(
      NavigationLinkWithStore(
        store.scope(state: \.settingsState, action: ProfileAction.settings),
        mapState: replayNonNil(),
        onDeactivate: { ViewStore(store.stateless)
          .send(.settingsView(isNavigation: false))
        },
        destination: SettingsView.init(store:)
      )
    )
  }
}

// struct ProfileView_Previews: PreviewProvider {
//
//  static let store = Store(
//    initialState: ProfileState.profileStateWithUserWithAvatar,
//    reducer: profileReducer,  // here i am mixing
//    environment: ProfileEnvironment.happyPath
//  )
//
//  static var previews: some View {
//
//    Group {
//      NavigationView {
//        ProfileView(store: store)
//      }
//
//      NavigationView {
//        ProfileView(store: store)
//          .environment(\.colorScheme, .dark)
//      }
//    }
//  }
// }

public struct ProfileImageOverlay: View {
  @Environment(\.colorScheme) var colorScheme

  let store: Store<ProfileState, ProfileAction>

  public init(store: Store<ProfileState, ProfileAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(
      self.store.scope(state: { $0.view }, action: ProfileAction.view)
    ) { viewStore in
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
            Text(viewStore.user.fullName)
              .foregroundColor(Color.black)
              .font(.title).bold()
              .frame(maxWidth: .infinity)
              .padding()
              .padding(.bottom, -5)
            Text(viewStore.user.phoneNumber)
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

// struct ProfileImageOverlay_Previews: PreviewProvider {
//  static let environment = ProfileEnvironment(
//    userClient: .happyPath,
//    eventClient: .happyPath,
//    authClient: .happyPath,
//    attachmentClient: .happyPath,
//    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
//  )
//
//  static let store = Store(
//    initialState: ProfileState(),
//    reducer: profileReducer,
//    environment: ProfileEnvironment(
//      userClient: .happyPath,
//      eventClient: .happyPath,
//      authClient: .happyPath,
//      attachmentClient: .happyPath,
//      mainQueue: DispatchQueue.main.eraseToAnyScheduler()
//    )
//  )
//
//  static var previews: some View {
//    ProfileImageOverlay(store: store)
//  }
// }

public struct MyEventListView: View {
  let store: Store<ProfileState, ProfileAction>

  public var body: some View {

    WithViewStore(self.store) { _ in
      VStack {
        Text("My Events").font(.title)
        ForEachStore(
          self.store.scope(state: \.myEvents, action: ProfileAction.event)
        ) { eventStore in
          WithViewStore(eventStore) { _ in
            // Button(action: { viewStore.send(.eventTapped(eventViewStore.state)) }) {
            EventRowView(store: eventStore)
            // }
            // .buttonStyle(PlainButtonStyle())
          }
  //        .padding([.leading, .trailing], 30)
        }
      }
    }
  }
}

public struct EventRowView: View {
  @Environment(\.colorScheme) var colorScheme

  public init(store: Store<EventResponse.Item, MyEventAction>) {
    self.store = store
  }

  public let store: Store<EventResponse.Item, MyEventAction>

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        Group {
          Text(viewStore.name)
            .font(.system(.title, design: .rounded))
            .lineLimit(2)
            .padding(.top, 8)
            .padding(.bottom, 3)

          Text(viewStore.addressName)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.blue)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(
            colorScheme == .dark
              ? Color(
                #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1))
              : Color(
                #colorLiteral(
                  red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)))
      )
      .padding([.leading, .trailing], 16)
      .padding([.top, .bottom], 5)
    }
  }
}
