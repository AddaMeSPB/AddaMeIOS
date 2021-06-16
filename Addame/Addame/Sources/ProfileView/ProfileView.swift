import ComposableArchitecture
import SwiftUI
import AsyncImageLoder
import UserClient
import KeychainService
import SwiftUIExtension
import SharedModels
import AuthenticationView
import HttpRequest

extension ProfileView {
  public struct ViewState: Equatable {
    public var alert: AlertState<ProfileAction>?
    public var isUploadingImage: Bool = false
    public var showingImagePicker = false
    public var inputImage: UIImage?
    public var moveToSettingsView = false
    public var moveToAuthView: Bool = false
    public var user: User = User.draff
    public var isUserHaveAvatarLink: Bool = false
  }

  public enum ViewAction: Equatable {
    case alertDismissed
    case isUploadingImage
    case showingImagePicker
    case moveToSettingsView
    case moveToAuthView

    case fetchMyData
    case uploadAvatar(_ image: UIImage)
    case updateUserName(String, String)
    case createAttachment(_ attachment: Attachment)

    case userResponse(Result<User, HTTPError>)
    case attacmentResponse(Result<Attachment, HTTPError>)
    case event(index: Int, action: MyEventAction)

    case resetAuthData
  }
}

public struct ProfileView: View {

  @Environment(\.colorScheme) var colorScheme
  let store: Store<ProfileState, ProfileAction>

  public init(store: Store<ProfileState, ProfileAction>) {
    self.store = store
  }

  @ViewBuilder
  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: ProfileAction.view )) { viewStore  in

      ScrollView {

        if viewStore.state.user.attachments == nil {
          Image(systemName: "person.fill")
            .font(.system(size: 200, weight: .medium))
            .frame(width: 450, height: 350)
            .foregroundColor(Color.backgroundColor(for: self.colorScheme))
            .overlay(
              ProfileImageOverlay(store: self.store)
                .padding(.top, 40),
              alignment: .bottomTrailing
            )
        }

        if viewStore.state.user.lastAvatarURLString != nil {
          AsyncImage(
            urlString: viewStore.state.user.lastAvatarURLString!,
            placeholder: {
              HUDProgressView(
                placeHolder: "Image uploading...",
                show: viewStore.binding(
                  get: { $0.isUploadingImage },
                  send: { _ in ViewAction.isUploadingImage }
                )
              )
              .frame(width: 350, height: 150)
              .padding(.top, 100)
              .padding(.bottom, 100)
            },
            image: {
              Image(uiImage: $0)
                .renderingMode(.original)
                .resizable()
            }
          )
//          .redacted(reason: .placeholder)
          .aspectRatio(contentMode: .fit)
          .overlay(
            ProfileImageOverlay(store: self.store),
            alignment: .bottomTrailing
          )
        }

        VStack(alignment: .leading) {
          Text("My Events:")
            .font(.system(size: 23, weight: .bold, design: .rounded))
            .padding(.top, 10)
            .padding()
        }

        Divider()

        MyEventListView(store: self.store)

        Divider()

        HStack {
          Button(action: {
            viewStore.send(.resetAuthData)
            //            self.uvm.resetAuthData()
            //            self.uvm.moveToAuthView = true
          }) {
            Text("Logout")
              .font(.title)
              .bold()
          }
          //          .background(
          //            NavigationLink.init(
          //              destination: AuthView(authViewModel: self.avm, userViewModel: self.uvm)
          //                .onAppear(perform: {
          //                  //appState.tabBarIsHidden = true
          //                })
          //                .navigationBarTitle(String.empty)
          //                .navigationBarHidden(true),
          //              isActive: self.$uvm.moveToAuthView,
          //              label: {}
          //            )
          //          )
        }
        .padding(.bottom, 45)
      }
      .navigationBarTitle("Profile", displayMode: .inline)
      //      .sheet(isPresented: self.$uvm.showingImagePicker, onDismiss: self.uvm.loadImage) {
      //        ImagePicker(image: self.$uvm.inputImage)
      //      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing ) { settings }
      }
      .onAppear {
        viewStore.send(.fetchMyData)
      }
      .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
    }
  }

  private var settings: some View {
    Button(action: {
      // self.uvm.moveToSettingsView = true
    }) {
      Image(systemName: "gear")
        .font(.title)
      //        .foregroundColor(Color("bg"))
    }
    //    .background(
    //      NavigationLink(
    //        destination: SettingsView()
    //          .edgesIgnoringSafeArea(.bottom)
    //          .onAppear(perform: {
    //            self.uvm.tabBarHideAction(true)
    //            self.uvm.moveToSettingsView = false
    //          })
    //          .onDisappear(perform: {
    //            self.uvm.tabBarHideAction(false)
    //          }),
    //        isActive: self.$uvm.moveToSettingsView
    //      ) {
    //        EmptyView()
    //      }
    //    )
  }
}

struct ProfileView_Previews: PreviewProvider {

  static let environment = ProfileEnvironment(
    userClient: .happyPath,
    eventClient: .happyPath,
    authClient: .happyPath,
    attachmentClient: .happyPath,
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: ProfileState.events,
    reducer: profileReducer, // here i am mixing
    environment: environment
  )

  static var previews: some View {
    Group {
      ProfileView(store: store)

      ProfileView(store: store)
        .environment(\.colorScheme, .dark)
    }
  }

}

public struct ProfileImageOverlay: View {

  @Environment(\.colorScheme) var colorScheme

  let store: Store<ProfileState, ProfileAction>

  public init(store: Store<ProfileState, ProfileAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: ProfileAction.view )) { viewStore in
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
              viewStore.send(.showingImagePicker)
            }, label: {
              Image(systemName: "camera")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 40, height: 40)
                .background(Color.green)
                .clipShape(Circle())
                .padding(.trailing, 30)
            })
            .imageScale(.large)
            .frame(width: 40, height: 40, alignment: .center/*@END_MENU_TOKEN@*/)
            .padding()

          }

          Spacer()

          Text(viewStore.user.fullName)
            .font(.title).bold()
            .foregroundColor(Color.backgroundColor(for: self.colorScheme))

        }
        .padding(6)
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
      ForEachStore(
        self.store.scope(state: \.myEvents, action: ProfileAction.event)
      ) { eventStore in
        WithViewStore(eventStore) { _ in
//          Button(action: { viewStore.send(.eventTapped(eventViewStore.state)) }) {
            EventRowView(store: eventStore)
//          }
//          .buttonStyle(PlainButtonStyle())
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
          Text(viewStore.name)
            .lineLimit(2)
            .foregroundColor(colorScheme  == .dark ? Color.white : Color.black)
            .font(.system(size: 23, weight: .light, design: .rounded))
            .padding(10)
            .padding(.leading, 10)

          Text(viewStore.addressName)
            .lineLimit(2)
            .font(.system(size: 15, weight: .light, design: .rounded))
            .foregroundColor(.blue)
            .padding([.leading, .bottom], 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundColor(colorScheme == .dark ? Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)) : Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)) )
        )
        .padding(10)
    }
  }

}
