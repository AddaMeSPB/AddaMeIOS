//
//  DateFormatter+Extension.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 03.09.2020.
//

import Foundation

extension DateFormatter {
  static var iso8601: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter
  }()
}
