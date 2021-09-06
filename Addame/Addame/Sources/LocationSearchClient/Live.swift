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
  public static let live = LocalSearchClient(
    search: { request in
      Effect.future { callback in
        MKLocalSearch(request: request).start { response, error in
          switch (response, error) {
          case let (.some(response), _):
            callback(.success(LocalSearchResponse(response: response)))

          case let (_, .some):
            callback(.failure(LocalSearchClient.Error()))

          case let (.none, .none):
            fatalError("It should not be possible that response and error are both nil.")
          }
        }
      }
    }
  )
}
