//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Combine
import Foundation
import FoundationExtension
import HttpRequest
import SharedModels

// swiftlint:disable all
extension ConversationClient {
  public static let happyPath = Self(
    create: { _, _ in
      let user = User(
        id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217",
        firstName: "Saroar", createdAt: Date(), updatedAt: Date()
      )

      let user1 = User(
        id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219",
        avatarUrl:
          "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
        firstName: "Alla", createdAt: Date(), updatedAt: Date()
      )

      let user2 = User(
        id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216",
        firstName: "Ksusha", createdAt: Date(), updatedAt: Date()
      )

      let conversation = Conversation(
        id: "5fbe8a8c492346f651b57946", title: "Walk Around 🚶🏽🚶🏼‍♀️2",
        type: .group, members: [user1, user2], admins: [user],
        lastMessage: nil, createdAt: Date(), updatedAt: Date()
      )

      let conversationItem = ConversationResponse.Item(conversation)

      return Just(
        conversationItem
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    addUserToConversation: { _, _ in
      Just(ConversationResponse.UserAdd.diff)
        .setFailureType(to: HTTPError.self)
        .eraseToAnyPublisher()
    },
    list: { _, _ in
      Just(
        ConversationResponse(
          items: [
            ConversationResponse.Item(
              Conversation(
                id: ObjectIdGenerator.shared.generate(), title: "Walk Around 🚶🏽🚶🏼‍♀️", type: .group,
                createdAt: Date(), updatedAt: Date())
            ),
            ConversationResponse.Item(
              Conversation(
                id: ObjectIdGenerator.shared.generate(),
                title: "+79218821217, Alla Fake Number Update", type: .oneToOne, createdAt: Date(),
                updatedAt: Date())
            ),
            ConversationResponse.Item(
              Conversation(
                id: ObjectIdGenerator.shared.generate(), title: "Running", type: .group,
                createdAt: Date(), updatedAt: Date())
            ),
          ],
          metadata: Metadata(per: 10, total: 10, page: 1)
        )
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    find: { _, _ in
      let user = User(
        id: "5fabb1ebaa5f5774ccfe48c3", phoneNumber: "+79218821217",
        firstName: "Saroar", createdAt: Date(), updatedAt: Date()
      )

      let user1 = User(
        id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218821219",
        avatarUrl:
          "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
        firstName: "Alla", createdAt: Date(), updatedAt: Date()
      )

      let user2 = User(
        id: "5fabb247ed7445b70914d0c9", phoneNumber: "+79218821216",
        firstName: "Ksusha", createdAt: Date(), updatedAt: Date()
      )

      let conversation = Conversation(
        id: "5fbe8a8c492346f651b57946", title: "Walk Around 🚶🏽🚶🏼‍♀️2",
        type: .group, members: [user1, user2], admins: [user],
        lastMessage: nil, createdAt: Date(), updatedAt: Date()
      )

      let conversationItem = ConversationResponse.Item(conversation)

      return Just(
        conversationItem
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }
  )
}
