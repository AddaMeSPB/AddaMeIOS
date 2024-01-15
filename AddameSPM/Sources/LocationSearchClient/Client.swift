//
//  LocalSearchClient.swift
//
//
//  Created by Saroar Khandoker on 06.07.2021.
//

import ComposableArchitecture
import MapKit

public struct LocalSearchClient {

    public var search: @Sendable (MKLocalSearch.Request) -> AsyncStream<LocalSearchResponse>
    
    public init(search: @escaping @Sendable (MKLocalSearch.Request) -> AsyncStream<LocalSearchResponse>) {
        self.search = search
    }

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}
