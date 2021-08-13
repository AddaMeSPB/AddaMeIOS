//
//  String+Date.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 29.09.2020.
//

import Foundation

public extension String {
  var toISO8601Date: Date? {
        ISO8601DateFormatter().date(from: self)
    }
}
