//
//  EventEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 12.04.2021.
//

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import PathMonitorClient
import EventClient
import Contacts
import UserDefaultsClient

public struct EventsEnvironment {

  let pathMonitorClient: PathMonitorClient
  var locationManager: LocationManager
  let eventClient: EventClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userDefaults: UserDefaultsClient

  public init(
    pathMonitorClient: PathMonitorClient,
    locationManager: LocationManager,
    eventClient: EventClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    userDefaults: UserDefaultsClient
  ) {
    self.pathMonitorClient = pathMonitorClient
    self.locationManager = locationManager
    self.eventClient = eventClient
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.userDefaults = userDefaults
  }

  func getCoordinate(_ location: Location) -> Effect<CLPlacemark, Never> {

    return Effect<CLPlacemark, Never>.future { callback in
      let address = CLGeocoder()
      address.reverseGeocodeLocation(
        CLLocation(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude
        )
      ) { placemarks, error in
        if error != nil {
          // callback(.failure( kCLLocationCoordinate2DInvalid, error as CoordinateError?))
        }

        if let placemark = placemarks?[0] {
//          let formatter = CNPostalAddressFormatter()
//          let addressString = formatter.string(from: placemark.postalAddress!)

          callback(.success(placemark))
        }
      }
    }
  }

}
