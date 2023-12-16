//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 06.07.2021.
//

import ComposableArchitecture
import MapKit

extension LocalSearchClient {
    public static func unimplemented(
        search: @Sendable @escaping (MKLocalSearch.Request) -> AsyncStream<LocalSearchResponse> = { _ in
            AsyncStream<LocalSearchResponse> { continuation in
                // Here, you can send a mock response or end the stream immediately
                // For example, ending the stream immediately:
                continuation.finish()

                // Alternatively, you can yield a mock LocalSearchResponse if needed
                // continuation.yield(LocalSearchResponse(/* Mock data */))
            }
        }
    ) -> Self {
        Self(search: search)
    }
}
