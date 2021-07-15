//
//  LocalSearchClient.swift
//  
//
//  Created by Saroar Khandoker on 06.07.2021.
//

import ComposableArchitecture
import MapKit

public struct LocalSearchClient {

  public var search: (MKLocalSearch.Request) -> Effect<LocaSearchResponse, Error>

  public init(
    search: @escaping (MKLocalSearch.Request
  ) -> Effect<LocaSearchResponse, Error>) {
    self.search = search
  }

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }

}
