//
//  Array+RemoveDuplicate.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 17.10.2020.
//

import Foundation

public extension Array where Element: Hashable {
  func uniqElemets() -> [Element] {
    let set = Set(self)
    return Array(set)
  }
}
