//
//  LocationSearchReducer.swift
//  LocationSearchReducer
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import Combine
import ComposableArchitecture
import Contacts
import MapKit
import SwiftUI

private struct LocationManagerId: Hashable {}
private struct CancelSearchId: Hashable {}

public let locationSearchReducer = Reducer<
  LocationSearchState, LocationSearchAction, LocationEnvironment
> { state, action, environment in
  switch action {
  case .onAppear:
    return environment
      .localSearch.create(LocationManagerId(), [.address, .pointOfInterest])
      .map(LocationSearchAction.locationSearchManager)

  case .onDisappear:
    return environment
      .localSearch.destroy(id: LocationManagerId())
      .fireAndForget()

  case let .searchTextInputChanged(string):

    state.searchTextInput = string
    return environment.localSearch
      .query(id: LocationManagerId(), fragment: string)
      .receive(on: DispatchQueue.main)
      .debounce(for: .milliseconds(150), scheduler: RunLoop.main, options: nil)
      .fireAndForget()

  case let .textFieldHeightChanged(height):
    let minHeight: CGFloat = 50
    let maxHeight: CGFloat = 100

    if height < minHeight {
      state.textFieldHeight = minHeight
      return .none
    }

    if height > maxHeight {
      state.textFieldHeight = maxHeight
      return .none
    }

    state.textFieldHeight = height

    return .none
  case let .isEditing(trigger):
    if trigger == false {
      state.searchTextInput = ""
    }
    state.isEditing = trigger
    return .none

  case let .locationSearchManager(.completerDidUpdateResults(completer: completer)):
    state.pointsOfInterest = .init(uniqueElements: completer.results)
    return .none

  case .locationSearchManager:
    return .none

  case let .cleanSearchText(isClean):
    if isClean { state.searchTextInput = "" }
    return .none

  case let .eventCoordinate(.success(coordinate)):
    return .none

  case let .didSelect(address: results):
    let address = results.title  // + " " + results.subtitle
    return environment.getCoordinate(address)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(LocationSearchAction.eventCoordinate)

  case let .pointOfInterest(index: index, address: address):
    return .none
  }
}
.combined(
  with:
    locationManagerReducer
    .pullback(
      state: \.self,
      action: /LocationSearchAction.locationSearchManager,
      environment: { $0 }
    )
)
// .signpost()
// .debug()

private let locationManagerReducer = Reducer<
  LocationSearchState, LocalSearchManager.Action, LocationEnvironment
> { state, action, _ in
  switch action {
  case let .completerDidUpdateResults(completer: completer):
    state.pointsOfInterest = .init(uniqueElements: completer.results)
    return .none
  case let .completer(_, didFailWithError: didFailWithError):
    return .none
  }
}

extension MKPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress, style: .mailingAddress
    )
    .replacingOccurrences(of: "\n", with: " ")
  }
}
