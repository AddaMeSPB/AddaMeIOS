//
//  LocationSearchState.swift
//  LocationSearchState
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import Combine
import ComposableArchitecture
import Foundation
import MapKit
import Network
import SwiftUI
import SwiftUIExtension
import AddaSharedModels

extension LocationSearch.State {
  public static let locationSearchPlacholder = Self(
    searchTextInput: "",
    placeMark: Placemark(coordinate: CLLocationCoordinate2D(latitude: 60.006 , longitude: 30.38752), title: "улица Вавиловых, 8 к1, Saint Petersburg, Russia, 195257")
  )
  // "Тихорецкий проспект, 3БЕ Санкт-Петербург, Россия, 194064"
}

extension MKLocalSearchCompletion: Identifiable {}
