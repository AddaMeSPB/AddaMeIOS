//
//  LocationSearchAction.swift
//  LocationSearchAction
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import ComposableArchitecture
import MapKit
import SwiftUI

extension LocationSearch.Action {
  // swiftlint:disable cyclomatic_complexity superfluous_disable_command
  static func view(_ localAction: LocationSearchView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return onAppear
    case .onDisappear:
      return onDisappear
    case .alertDismissed:
        return alertDismissed
    case let .searchTextInputChanged(inputText):
      return searchTextInputChanged(inputText)
    case let .textFieldHeightChanged(height):
      return textFieldHeightChanged(height)
    case let .isEditing(trigger):
      return isEditing(trigger)
    case let .locationSearchManager(action):
      return locationSearchManager(action)
    case let .cleanSearchText(isClean):
      return .cleanSearchText(isClean)
    case let .didSelect(address: results):
      return .didSelect(address: results)
    case let .pointOfInterest(index: index, address: address):
      return .pointOfInterest(index: index, address: address)
    case .region(let cr):
        return .region(cr)
    case .backToformView:
        return .backToformView
    }
  }
}
