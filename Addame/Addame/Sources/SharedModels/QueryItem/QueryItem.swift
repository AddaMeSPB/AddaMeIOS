//
//  QueryItem.swift
//  
//
//  Created by Saroar Khandoker on 23.02.2021.
//

import Foundation

public struct QueryItem: Codable {
  public init(page: String, per: String, lat: String? = nil, long: String? = nil, distance: String? = nil) {
    self.page = page
    self.per = per
    self.lat = lat
    self.long = long
    self.distance = distance
  }

  public var page: String
  public var per: String
  public var lat: String?
  public var long: String?
  public var distance: String?

  public var parameters: [String: Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(
        uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any
      ) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}
