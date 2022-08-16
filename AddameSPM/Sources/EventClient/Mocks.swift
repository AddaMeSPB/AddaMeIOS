//
//  EventClient.swift
//
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import AddaSharedModels

// swiftlint:disable all
extension EventClient {
  private static let data = Date(timeIntervalSince1970: 0)
  public static let empty = Self(
    events: { _ in EventsResponse.draffEmpty },
    create: { _ in EventResponse.emptyDraff },
    categoriesFetch: { CategoriesResponse.draff }
  )

  public static let happyPath = Self(
    events: { _ in EventsResponse.draff },
    create: { _ in EventResponse.runningDraff },
    categoriesFetch: { CategoriesResponse.draff }
  )
}
