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

extension HangoutDetailsView {
    public struct ViewState: Equatable {
        init(
            alert: AlertState<HangoutDetails.Action>? = nil,
            event: EventResponse,
            pointsOfInterest: [PointOfInterest] = [],
            region: CoordinateRegion? = nil,
            conversation: ConversationOutPut? = nil,
            conversationMembers: [UserOutput],
            conversationAdmins: [UserOutput],
            chatMembers: Int,
            conversationOwnerName: String,
            isMember: Bool,
            isAdmin: Bool,
            isMovingChatRoom: Bool
        ) {
            self.alert = alert
            self.event = event
            self.pointsOfInterest = pointsOfInterest
            self.region = region
            self.conversation = conversation
            self.conversationMembers = conversationMembers
            self.conversationAdmins = conversationAdmins
            self.chatMembers = chatMembers
            self.conversationOwnerName = conversationOwnerName
            self.isMember = isMember
            self.isAdmin = isAdmin
            self.isMovingChatRoom = isMovingChatRoom
        }

        public var alert: AlertState<HangoutDetails.Action>?
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
        WithViewStore(self.store.scope(state: { $0.view }, action: HangoutDetails.Action.view)) { viewStore in
            ScrollView {
                VStack {
                    if viewStore.event.imageUrl != nil {
                        AsyncImage(
                            url: URL(string: viewStore.event.imageUrl!)!,
                            placeholder: {
                                ProgressView()
                                    .frame(
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.height / 2.3,
                                        alignment: .center
                                    )
                                    .background(Color.gray)
                            },
                            image: {
                                Image(uiImage: $0).resizable()
                            }
                        )
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

                    MapView(
                        pointsOfInterest: viewStore.pointsOfInterest,
                        region: viewStore.binding(
                            get: { $0.region },
                            send: HangoutDetailsView.ViewAction.updateRegion
                        ),
                        isHangoutDetailsView: true
                    )
                    .edgesIgnoringSafeArea([.all])
                    .frame(height: 400)
                    .padding(.bottom, 20)
                }  // VStack
            }  // ScrollView
            .background(Color(.systemBackground))
        }
        .onAppear {
            ViewStore(store.stateless).send(.onAppear)
        }
    }
}

struct HangoutDetailsView_Previews: PreviewProvider {
    
    static let store = Store(
        initialState: HangoutDetails.State.placeHolderEvent,
        reducer: HangoutDetails()
    )
    
    static var previews: some View {
        NavigationView {
            HangoutDetailsView(store: store)
        }
    }
}
