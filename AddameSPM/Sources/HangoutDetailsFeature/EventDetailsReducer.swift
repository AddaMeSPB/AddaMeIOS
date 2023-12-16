//
//  HangoutDetailsReducer.swift
//
//
//  Created by Saroar Khandoker on 05.07.2021.
//

import ChatView
import ComposableArchitecture
import KeychainClient
import MapKit
import MapView
import AddaSharedModels
import SwiftUI
import APIClient

public struct HangoutDetails: Reducer {
    public struct State: Equatable {
        public init(
            alert: AlertState<HangoutDetails.AlertAction>? = nil,
            event: EventResponse,
            owner: UserOutput = .withFirstName,
            pointsOfInterest: [PointOfInterest] = [],
            region: CoordinateRegion? = nil,
            conversation: ConversationOutPut? = nil,
            conversationMembers: [UserOutput] = [],
            conversationAdmins: [UserOutput] = [],
            chatMembers: Int = 0,
            conversationOwnerName: String = "",
            isMember: Bool = false,
            isAdmin: Bool = false,
            isMovingChatRoom: Bool = false
        ) {
            self.alert = alert
            self.event = event
            self.owner = owner
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

        @PresentationState var alert: AlertState<AlertAction>?
        public let event: EventResponse
        public var owner: UserOutput
        public var pointsOfInterest: [PointOfInterest] = []
        public var region: CoordinateRegion?
        public var conversation: ConversationOutPut?
        public var conversationMembers: [UserOutput] = []
        public var conversationAdmins: [UserOutput] = []
        public var chatMembers: Int = 0

        public var conversationOwnerName: String = ""
        public var isMember: Bool = false
        public var isAdmin: Bool = false
        public var isMovingChatRoom: Bool = false
    }

    public enum Action: Equatable {
        case alert(PresentationAction<AlertAction>)
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

    public enum AlertAction: Equatable {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert:
                    return .none
        
            case .onAppear:

                let latitude = state.event.coordinates[0]
                let longitude = state.event.coordinates[1]

                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                state.region = CoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )

                state.pointsOfInterest = [
                    .init(coordinate: coordinate, subtitle: state.event.addressName, title: state.event.name)
                ]

                if let members = state.conversation?.members {
                    state.chatMembers = members.count
                    state.isMember = members.contains(where: { $0.id == state.owner.id })
                }

                return .run { [ownerId = state.event.ownerId.hexString] send in
                    await send(.userResponse(
                        await TaskResult {
                            try await apiClient.request(
                                for: .authEngine(.users(.user(id: ownerId, route: .find))),
                                as: UserOutput.self,
                                decoder: .iso8601
                            )
                        }
                    ))
                }

            case .alertDismissed:
                return .none
            case .moveToChatRoom:
                return .none
            case .updateRegion:
                return .none
            case .startChat:
                return .none
            case .askJoinRequest:
                return .none
            case .joinToEvent:
                return .none

            case let .conversationResponse(.success(conversationItem)):

                state.conversation = conversationItem

                do {
                    state.owner = try self.keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
                } catch {
                    state.alert = .init(title: .init("\(#line) cant user!"))
                    print("something....")
                    return .none
                }

                if let members = conversationItem.members {
                    state.chatMembers = members.count
                    state.isMember = members.contains(where: { $0.id == state.owner.id })
                }

                if let admins = conversationItem.admins {
                    state.isAdmin = admins.contains(where: { $0.id == state.owner.id })
                }

                return .none

            case .conversationResponse(.failure):
                return .none

            case let .userResponse(.success(userOutput)):
                state.owner = userOutput
                state.conversationOwnerName = userOutput.fullName ?? ""
                return .run { [conversationID = state.event.conversationsId] send in
                      await send(  .conversationResponse(
                            await TaskResult {
                                try await apiClient.request(
                                    for: .chatEngine(.conversations(.conversation(id: conversationID.hexString))),
                                    as: ConversationOutPut.self,
                                    decoder: .iso8601
                                )
                            }
                        ))
                    }

            case .userResponse(.failure):
                // handle error
                return .none
            }
        }
    }
}
