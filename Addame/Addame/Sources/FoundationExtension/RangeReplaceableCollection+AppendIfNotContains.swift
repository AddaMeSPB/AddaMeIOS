//
//  RangeReplaceableCollection+AppendIfNotContains.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 22.10.2020.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
  @discardableResult
  public mutating func appendIfNotContains(_ element: Element) -> (
    appended: Bool, memberAfterAppend: Element
  ) {
    if let index = firstIndex(of: element) {
      return (false, self[index])
    } else {
      append(element)
      return (true, element)
    }
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  public mutating func prependUnique(_ element: Element) {
    if let index = firstIndex(of: element) {
      remove(at: index)
    }
    insert(element, at: startIndex)
  }
}
