//
//  String+Replace.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 24.10.2020.
//

import Foundation

extension String {
  public func replace(target: String, withString: String) -> String {
    return replacingOccurrences(
      of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
  }
}
