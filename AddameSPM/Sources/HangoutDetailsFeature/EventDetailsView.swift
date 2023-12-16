//
//  HangoutDetailsView.swift
//
//
//  Created by Saroar Khandoker on 05.07.2021.
//

import AsyncImageLoder
import ChatView
import ComposableArchitecture
import ComposableArchitectureHelpers
import ComposableCoreLocation

import KeychainClient
import MapKit
import MapView
import AddaSharedModels
import SwiftUI
import SwiftUIExtension
import NukeUI


extension HangoutDetailsView {
    public struct ViewState: Equatable {
        init(state: HangoutDetails.State) {
            self.event = state.event
            self.pointsOfInterest = state.pointsOfInterest
            self.region = state.region
            self.conversation = state.conversation
            self.conversationMembers = state.conversationMembers
            self.conversationAdmins = state.conversationAdmins
            self.chatMembers = state.chatMembers
            self.conversationOwnerName = state.conversationOwnerName
            self.isMember = state.isMember
            self.isAdmin = state.isAdmin
            self.isMovingChatRoom = state.isMovingChatRoom
        }

        public let event: EventResponse
        public var owner: UserOutput = .withFirstName
        public var pointsOfInterest: [PointOfInterest] = []
        public var region: CoordinateRegion?
        public var conversation: ConversationOutPut?
        public var conversationMembers: [UserOutput]
        public var conversationAdmins: [UserOutput]
        public var chatMembers: Int

        public var conversationOwnerName: String
        public var isMember: Bool
        public var isAdmin: Bool
        public var isMovingChatRoom: Bool
    }

    public enum ViewAction: Equatable {
        case onAppear
        case alertDismissed
        case moveToChatRoom(Bool)
        case updateRegion(CoordinateRegion?)
        case startChat(Bool)
        case askJoinRequest(Bool)
        case joinToEvent(TaskResult<AddUser>)
        case conversationResponse(TaskResult<ConversationOutPut>)
        case userResponse(TaskResult<UserOutput>)
    }

}

public struct HangoutDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode

    private let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]

    public init(store: StoreOf<HangoutDetails>) {
        self.store = store
    }

    public let store: StoreOf<HangoutDetails>

    @ViewBuilder
    public var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ScrollView {
                VStack {
                    if viewStore.event.imageUrl != nil {

                        LazyImage(
                            request: ImageRequest(
                                url: URL(string: viewStore.event.imageUrl!)!
                            )
                        ) { state in

                            if let image = state.image {
                                image.resizable()
                            } else if state.error != nil {
                                Image(systemName: "person")
                                    .resizable()
                                    .padding()
                            } else {
                                ProgressView()
                                    .frame(
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.height / 2.3,
                                        alignment: .center
                                    )
                                    .background(Color.gray)
                            }
                        }
                        .padding(.bottom, 20)
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.top)
                        .overlay(
                            HangoutDetailsOverlayView(store: self.store)
                                .padding(.bottom, 25),
                            alignment: .bottomTrailing
                        )
                        .overlay(
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .frame(width: 60, height: 60, alignment: .center)
                            }
                                .padding([.top, .trailing], 10),
                            alignment: .topTrailing
                        )

                    } else {


                    /// Preview crash for this
                    Image(uiImage: UIImage(named: "hangout_dt", in: Bundle.module, with: nil)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 20)
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.top)
                        .overlay(
                            HangoutDetailsOverlayView(store: self.store)
                                .padding(.bottom, 25),
                            alignment: .bottomTrailing
                        )
                        .overlay(
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .frame(width: 60, height: 60, alignment: .center)
                            }
                                .padding([.top, .trailing], 10),
                            alignment: .topTrailing
                        )
                    }

                    if viewStore.chatMembers > 0 {
                        Text("Event friends: \(viewStore.chatMembers)")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
                            .font(.system(size: 23, weight: .light, design: .rounded))
                        Divider()
                            .padding(.bottom, -10)

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(viewStore.conversationMembers) { member in
                                    VStack(alignment: .leading) {
                                        if member.imageURL != nil {
                                            AsyncImage(
                                                url: member.imageURL!,
                                                placeholder: {
                                                    ProgressView()
                                                },
                                                image: {
                                                    Image(uiImage: $0).resizable()
                                                }
                                            )
                                            .aspectRatio(contentMode: .fit)
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                            .clipShape(Circle())
                                            .padding()
                                        } else {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                                .clipShape(Circle())
                                                .padding()
                                        }

                                        Text(member.fullName ?? "")
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                            .lineLimit(1)
                                        //   alignmentGuide(.center)
                                        // { viewDimensions in viewDimensions[.leading] }
                                            .font(.system(size: 15, weight: .light, design: .rounded))
                                        Spacer()
                                    }
                                    .padding()
                                }
                            }
                        }

                        Spacer()
                        Divider()
                    }

                    VStack(alignment: .leading) {
                        Text("Event Location:")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
                            .font(.system(size: 23, weight: .light, design: .rounded))
                            .padding()
                    }

//                    MapView(
//                        pointsOfInterest: viewStore.pointsOfInterest,
//                        region: viewStore.binding(
//                            get: { $0.region },
//                            send: { $0.updateRegion }
//                        ),
//                        isHangoutDetailsView: true
//                    )
//                    .edgesIgnoringSafeArea([.all])
//                    .frame(height: 400)
//                    .padding(.bottom, 20)
                }  // VStack
                .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
            }  // ScrollView
            .background(Color(.systemBackground))
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct HangoutDetailsView_Previews: PreviewProvider {
    
    static let store = Store(
        initialState: HangoutDetails.State.placeHolderEvent
    ) {
        HangoutDetails()
    }

    static var previews: some View {
        NavigationView {
            HangoutDetailsView(store: store)
        }
    }
}
