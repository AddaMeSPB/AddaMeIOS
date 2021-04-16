//
//  Date+Extension.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 03.09.2020.
//

import Foundation

public extension Date {
  var toISO8601String: String? {
    ISO8601DateFormatter().string(from: self)
  }
  
  func getFormattedDate(format: String) -> String {
    let dateformat = DateFormatter()
    dateformat.locale = Locale.current
    dateformat.dateFormat = format
    return dateformat.string(from: self)
  }
  
  var hour : Int {
    let components = Calendar.current.dateComponents([.hour ], from: self)
    return components.hour ?? 0
  }
  
  var minute : Int {
    let components = Calendar.current.dateComponents([.minute ], from: self)
    return components.minute ?? 0
  }
  
  var hourMinuteString : String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }
  
  var dayMonthYear : String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: self)
  }
  
  var dateFormatter: String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.autoupdatingCurrent
    
    let timeSinceDateInSconds = Date().timeIntervalSince(self)
    let secondInDay: TimeInterval = 24*60*60
    
    if timeSinceDateInSconds > 7 * secondInDay {
      dateFormatter.dateFormat = "MM/dd/yy"
    } else if timeSinceDateInSconds > secondInDay {
      dateFormatter.dateFormat = "EEEE"
    } else {
      dateFormatter.timeStyle = .short
      dateFormatter.string(from: self)
    }
    
    return dateFormatter.string(from: self)
  }
}
