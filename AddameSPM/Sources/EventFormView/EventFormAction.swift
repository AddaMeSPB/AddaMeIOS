//
//  EventFormAction.swift
//  EventFormAction
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import ComposableArchitecture
import Foundation
import MapKit
import MapView
import AddaSharedModels
import SwiftUI
import BSON

extension HangoutForm.Action {
  // swiftlint:disable cyclomatic_complexity
 init(action: EventFormView.ViewAction) {
    switch action {
    case .onAppear:
      self = .onAppear
    case .onDisappear:
      self = .onDisappear
    case let .titleChanged(string):
      self = .titleChanged(string)
    case let .textFieldHeightChanged(value):
      self = .textFieldHeightChanged(value)
    case let .selectedDurations(duration):
      self = .selectedDurations(duration)
    case let .selectedDurationIndex(int):
      self = .selectedDurationIndex(int)
    case let .selectedCategory(category):
        self = .selectedCategory(category)
    case let .showCategorySheet(isPresent):
      self = .showCategorySheet(isPresent)
    case let .liveLocationToggleChanged(liveLocationEnabled):
      self = .liveLocationToggleChanged(liveLocationEnabled)
    case let .isLocationSearch(navigate: active):
      self = .isLocationSearch(navigate: active)
    case let .locationSearch(action):
      self = .locationSearch(action)
    case .submitButtonTapped:
      self = .submitButtonTapped
    case .actionSheetButtonTapped:
      self = .actionSheetButtonTapped
    case .actionSheetDismissed:
      self = .actionSheetDismissed

    }
  }
}
