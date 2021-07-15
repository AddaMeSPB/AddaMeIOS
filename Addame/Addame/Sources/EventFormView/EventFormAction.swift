//
//  EventFormAction.swift
//  EventFormAction
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import SharedModels
import HttpRequest
import MapView
import MapKit

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
  case successFullMsg
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
      return self.didAppear
    case .didDisappear:
      return self.didDisappear
    case let .titleChanged(string):
      return self.titleChanged(string)
    case let .textFieldHeightChanged(value):
      return self.textFieldHeightChanged(value)
    case let .selectedDurations(duration):
      return self.selectedDurations(duration)
    case let .selectedCategories(categories):
      return self.selectedCategories(categories)
    case let .selectedDurationIndex(int):
      return self.selectedDurationIndex(int)
    case let .showCategorySheet(isPresent):
      return self.showCategorySheet(isPresent)
    case let .liveLocationToggleChanged(liveLocationEnabled):
      return self.liveLocationToggleChanged(liveLocationEnabled)
    case let .isSearchSheet(isPresented: isPresented):
      return self.isSearchSheet(isPresented: isPresented)
    case let .locationSearch(action):
      return self.locationSearch(action)
    case .submitButtonTapped:
      return .submitButtonTapped
    case .actionSheetButtonTapped:
      return self.actionSheetButtonTapped
    case .actionSheetDismissed:
      return self.actionSheetDismissed

    }
  }
}
