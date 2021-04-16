//
//  String+Replace.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 24.10.2020.
//

import Foundation

public extension String {
  func replace(target: String, withString: String) -> String {
    return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
  }
}
