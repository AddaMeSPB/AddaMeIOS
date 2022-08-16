//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 05.03.2021.
//

import ChatClient
import Combine
import Foundation
import HTTPRequestKit
import InfoPlist
import KeychainService
import AddaSharedModels
import URLRouting

extension ChatClient {
    public static var live: ChatClient = .init(
        messages: { query, conversationId in
            return try await ChatClient.apiClient.decodedResponse(
                for: .chatEngine(
                    .conversations(
                        .conversation(id: conversationId, route: .messages(.list(query: query)))
                    )
                ),
                as: MessagePage.self,
                decoder: .ISO8601JSONDecoder
            ).value
        }
      )

}
