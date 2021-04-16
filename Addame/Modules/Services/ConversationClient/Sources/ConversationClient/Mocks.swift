//
//  Mocks.swift
//  
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Combine
import Foundation
import FuncNetworking
import AddaMeModels
import FoundationExtension

extension ConversationClient {
  static public let happyPath = Self(
    create: { _,_  in
      Just(
        ConversationResponse.Item(Conversation(id: ObjectIdGenerator.shared.generate(), title: "Walk Around 🚶🏽🚶🏼‍♀️", type: .group, createdAt: Date(), updatedAt: Date()))
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    addUserToConversation: { _,_   in
      Just("")
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    list: { _,_  in
      Just(
        ConversationResponse.init(
          items: [
            ConversationResponse.Item(
              Conversation(id: ObjectIdGenerator.shared.generate(), title: "Walk Around 🚶🏽🚶🏼‍♀️", type: .group, createdAt: Date(), updatedAt: Date())
            ),
            ConversationResponse.Item(
              Conversation(id: ObjectIdGenerator.shared.generate(), title: "+79218821217, Alla Fake Number Update", type: .oneToOne, createdAt: Date(), updatedAt: Date())
            ),
            ConversationResponse.Item(
              Conversation(id: ObjectIdGenerator.shared.generate(), title: "Running", type: .group, createdAt: Date(), updatedAt: Date())
            )
          ],
          metadata: Metadata(per: 10, total: 10, page: 1)
        )
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    },
    find: { _,_   in
      Just(
          ConversationResponse.Item(
            Conversation(id: ObjectIdGenerator.shared.generate(), title: "Walk Around 🚶🏽🚶🏼‍♀️", type: .group, createdAt: Date(), updatedAt: Date())
          )
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }
  )
  
}
