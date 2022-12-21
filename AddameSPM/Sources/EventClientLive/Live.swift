//
//  EventClientLive.swift
//
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import EventClient
import Foundation
import InfoPlist
import AddaSharedModels
import URLRouting

extension EventClient {

    public static var live: EventClient = .init(
        events: { query in
            return try await EventClient.apiClient.decodedResponse(
                for: .eventEngine(.events(.list(query: query))),
                as: EventsResponse.self,
                decoder: .ISO8601JSONDecoder
            ).value
        },
        create: { input in
            return try await EventClient.apiClient.decodedResponse(
                for: .eventEngine(.events(.create(eventInput: input))),
                as: EventResponse.self,
                decoder: .ISO8601JSONDecoder
            ).value
        },
        categoriesFetch: {
            return try await EventClient.apiClient.decodedResponse(
                for: .eventEngine(.categories(.list)),
                as: CategoriesResponse.self,
                decoder: .ISO8601JSONDecoder
            ).value
        }
    )

}
