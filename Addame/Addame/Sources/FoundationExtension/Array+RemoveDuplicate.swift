//
//  Array+RemoveDuplicate.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 17.10.2020.
//

import Foundation

extension Array where Element: Hashable {
  public func uniqElemets() -> [Element] {
    let set = Set(self)
    return Array(set)
  }
}
