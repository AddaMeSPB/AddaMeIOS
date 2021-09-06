//
//  EventFormAction.swift
//  EventFormAction
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import ComposableArchitecture
import Foundation
import HttpRequest
import MapKit
import MapView
import SharedModels
import SwiftUI

public enum EventFormAction: Equatable {
  case didAppear
  case didDisappear
  case titleChanged(String)
  case textFieldHeightChanged(CGFloat)
  case selectedDurations(DurationButtons)
  case selectedCategories(Categories)
  case selectedDurationIndex(Int)
  case showCategorySheet(Bool)
  case liveLocationToggleChanged(Bool)
  case isSearchSheet(isPresented: Bool)
  case locationSearch(LocationSearchAction)
  case eventsResponse(Result<Event, HTTPError>)
  case backToPVAfterCreatedEventSuccessfully

  case submitButtonTapped
  case actionSheetButtonTapped
  case actionSheetCancelTapped
  case actionSheetDismissed
  case alertButtonTapped
  case alertCancelTapped
  case alertDismissed
}

extension EventFormAction {
  // swiftlint:disable cyclomatic_complexity
  static func view(_ localAction: EventFormView.ViewAction) -> Self {
    switch localAction {
    case .didAppear:
      return didAppear
    case .didDisappear:
      return didDisappear
    case let .titleChanged(string):
      return titleChanged(string)
    case let .textFieldHeightChanged(value):
      return textFieldHeightChanged(value)
    case let .selectedDurations(duration):
      return selectedDurations(duration)
    case let .selectedCategories(categories):
      return selectedCategories(categories)
    case let .selectedDurationIndex(int):
      return selectedDurationIndex(int)
    case let .showCategorySheet(isPresent):
      return showCategorySheet(isPresent)
    case let .liveLocationToggleChanged(liveLocationEnabled):
      return liveLocationToggleChanged(liveLocationEnabled)
    case let .isSearchSheet(isPresented: isPresented):
      return isSearchSheet(isPresented: isPresented)
    case let .locationSearch(action):
      return locationSearch(action)
    case .submitButtonTapped:
      return .submitButtonTapped
    case .actionSheetButtonTapped:
      return actionSheetButtonTapped
    case .actionSheetDismissed:
      return actionSheetDismissed
    }
  }
}
