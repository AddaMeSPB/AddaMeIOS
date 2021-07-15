//
//  LocationSearchState.swift
//  LocationSearchState
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import Foundation
import ComposableArchitecture
import Combine
import SwiftUI
import SwiftUIExtension
import Network
import MapKit

// swiftlint:disable file_length superfluous_disable_command

extension LocationSearchState {
  public static let locationSearchPlacholder = Self(
    searchTextInput: ""
  )
  // "Тихорецкий проспект, 3БЕ Санкт-Петербург, Россия, 194064"
}

extension MKLocalSearchCompletion: Identifiable {}

public struct LocationSearchState: Equatable, Hashable, Identifiable {

  public init(
    id: UUID = UUID(),
    searchTextInput: String = "",
    textFieldHeight: CGFloat = 50,
    isEditing: Bool = false,
    pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = [],
    isDidSelectedAddress: Bool = false
  ) {
    self.id = id
    self.searchTextInput = searchTextInput
    self.textFieldHeight = textFieldHeight
    self.isEditing = isEditing
    self.pointsOfInterest = pointsOfInterest
    self.isDidSelectedAddress = isDidSelectedAddress
  }

  public let id: UUID
  public var searchTextInput: String = ""
  public var textFieldHeight: CGFloat = 50
  public var isEditing: Bool = false
  public var pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = []
  public var isDidSelectedAddress: Bool = false

}

extension LocationSearchState {
  var view: LocationSearchView.ViewState {
    LocationSearchView.ViewState(
      id: self.id,
      searchTextInput: self.searchTextInput,
      textFieldHeight: self.textFieldHeight,
      isEditing: self.isEditing,
      pointsOfInterest: self.pointsOfInterest,
      isDidSelectedAddress: self.isDidSelectedAddress
    )
  }
}
