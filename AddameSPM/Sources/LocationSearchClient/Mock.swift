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
    search: @escaping (MKLocalSearch.Request) -> Effect<
      LocalSearchResponse, LocalSearchClient.Error
    > = { _ in fatalError("MKLocalSearch error from Mock") }
  ) -> Self {
    Self(search: search)
  }
}
