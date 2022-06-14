//
//  LocationEnvironment.swift
//  LocationEnvironment
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import Combine
import ComposableArchitecture
import IdentifiedCollections
import MapKit
import Network
import SwiftUI
import SwiftUIExtension

public struct LocationEnvironment {
  public var localSearch: LocalSearchManager
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    localSearch: LocalSearchManager,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.localSearch = localSearch
    self.mainQueue = mainQueue
  }

  func getCoordinate(_ addressString: String) -> Effect<CLPlacemark, Never> {
    return Effect<CLPlacemark, Never>.future { callback in
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(addressString) { placemarks, error in
        if error != nil {
          print(#line, error as Any)
          // callback(.failure( kCLLocationCoordinate2DInvalid, error as CoordinateError?))
        }

        if let placemark = placemarks?[0] {
          callback(.success(placemark))
        }
      }
    }
  }
}

extension LocationEnvironment {
  public static let live: LocationEnvironment = .init(
    localSearch: .live,
    mainQueue: .main
  )
}
