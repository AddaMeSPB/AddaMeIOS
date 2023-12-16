//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 06.07.2021.
//

import Combine
import ComposableArchitecture
import MapKit

extension LocalSearchClient {
    public static let live = LocalSearchClient(search: { request in
        AsyncStream { continuation in
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let response = response {
                    // Yield a success value to the stream
                    continuation.yield(with: .success(LocalSearchResponse(response: response)))
                    continuation.finish()
                } else if let error = error {
                    // Yield an error to the stream
                    // continuation.yield(with: .failure(Never))
                    print("Unexpected state: response and error \(error)")
                } else {
                    // Handle unexpected state
                    fatalError("Unexpected state: response and error are both nil.")
                }

                continuation.finish()
            }
        }
    })
}

