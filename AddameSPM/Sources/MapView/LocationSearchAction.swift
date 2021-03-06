//
//  LocationSearchAction.swift
//  LocationSearchAction
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import ComposableArchitecture
import MapKit
import SwiftUI

public enum LocationSearchAction: Equatable, Hashable {
  case onAppear
  case onDisappear
  case searchTextInputChanged(String)
  case textFieldHeightChanged(CGFloat)
  case isEditing(Bool)
  case locationSearchManager(LocalSearchManager.Action)
  case cleanSearchText(Bool)
  case didSelect(address: MKLocalSearchCompletion)
  case pointOfInterest(index: LocationSearchState.ID, address: MKLocalSearchCompletion)

  case eventCoordinate(Result<CLPlacemark, Never>)
}

extension LocationSearchAction {
  // swiftlint:disable cyclomatic_complexity superfluous_disable_command
  static func view(_ localAction: LocationSearchView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return onAppear
    case .onDisappear:
      return onDisappear
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
    }
  }
}
