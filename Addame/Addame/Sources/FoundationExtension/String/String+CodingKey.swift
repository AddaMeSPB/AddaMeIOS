//
//  String+CodingKey.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 28.09.2020.
//

import Foundation

extension String: CodingKey {
  public var stringValue: String {
    return self
  }

  public var intValue: Int? {
    return Int(self)
  }

  public init?(intValue: Int) {
    self.init(intValue.description)
  }

  public init?(stringValue: String) {
    self.init(stringValue)
  }
}
