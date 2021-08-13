//
//  DurationButtons.swift
//  DurationButtons
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import Foundation

public enum DurationButtons: String, CaseIterable, Equatable, Hashable {
  // swiftlint:disable identifier_name
  case FourHours = "4hr"
  case OneHour = "1hr"
  case TwoHours = "2hr"
  case ThreeHours = "3hr"

  public var value: Int {
    switch self {
    case .FourHours:
      return 240 * 60
    case .OneHour:
      return 60 * 60
    case .TwoHours:
      return 120 * 60
    case .ThreeHours:
      return 180 * 60
    }
  }

  static func getPositionBy(_ minutes: Int) -> String {
    switch minutes {
    case 240 * 60:
      return DurationButtons.allCases[0].rawValue
    case 30 * 60:
      return DurationButtons.allCases[1].rawValue
    case 60 * 60:
      return DurationButtons.allCases[2].rawValue
    case 120 * 60:
      return DurationButtons.allCases[3].rawValue
    case 180 * 60:
      return DurationButtons.allCases[4].rawValue
    default:
      return "Missing minutes"
    }
  }
}
