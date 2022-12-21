////
////  ConversationAPI.swift
////
////
////  Created by Saroar Khandoker on 22.02.2021.
////
//
// import Combine
// import ConversationClient
// import Foundation
// import FoundationExtension
// import InfoPlist
// import AddaSharedModels
// import URLRouting
//
// extension ConversationClient {
//    public static var live: ConversationClient =
//        .init(
//            create: { input in
//                return try await ConversationClient.apiClient.decodedResponse(
//                    for: .chatEngine(.conversations(.create(input: input))),
//                    as: ConversationOutPut.self,
//                    decoder: .iso8601
//                ).value
//            },
//            addUserToConversation: { addUserIDs in
//                return try await ConversationClient.apiClient.decodedResponse(
//                    for: .authEngine(
//                        .users(
//                            .user(
//                                id: addUserIDs.usersId.hexString,
//                                route: .conversations(
//                                    .conversation(
//                                        id: addUserIDs.conversationsId.hexString,
//                                        route: .joinuser
//                                    )
//                                )
//                            )
//                        )
//                    )
//                    ,
//                    as: AddUser.self,
//                    decoder: .iso8601
//                ).value
//            },
//            list: { query in
//                return try await ConversationClient.apiClient.decodedResponse(
//                    for: .chatEngine(.conversations(.list(query: query))),
//                    as: ConversationsResponse.self,
//                    decoder: .iso8601
//                ).value
//            },
//            find: { id in
//                return try await ConversationClient.apiClient.decodedResponse(
//                    for: .chatEngine(.conversations(.conversation(id: id, route: .find))),
//                    as: ConversationOutPut.self,
//                    decoder: .iso8601
//                ).value
//            }
//        )
//
// }
//
// extension Never: Encodable {
//    public func encode(to _: Encoder) throws {
//        fatalError("Never error called")
//    }
// }
