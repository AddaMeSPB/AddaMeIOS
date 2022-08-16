//
//  EventEnvironment.swift
//
//
//  Created by Saroar Khandoker on 12.04.2021.
//

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import EventClient
import EventClientLive
import PathMonitorClient
import PathMonitorClientLive
import UserDefaultsClient
import IDFAClient
import IDFAClientLive
import URLRouting
import AddaSharedModels

public struct EventsEnvironment {
  let pathMonitorClient: PathMonitorClient
  let locationManager: LocationManager
  let eventClient: EventClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userDefaults: UserDefaultsClient
  var idfaClient: IDFAClient

  public init(
    pathMonitorClient: PathMonitorClient,
    locationManager: LocationManager,
    eventClient: EventClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    userDefaults: UserDefaultsClient,
    idfaClient: IDFAClient
  ) {
    self.pathMonitorClient = pathMonitorClient
    self.locationManager = locationManager
    self.eventClient = eventClient
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.userDefaults = userDefaults
    self.idfaClient = idfaClient
  }

  func getPlacemark(_ location: Location) -> Effect<CLPlacemark, Never> {
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

extension EventsEnvironment {
  public static let live: EventsEnvironment = .init(
    pathMonitorClient: .live(queue: .main),
    locationManager: .live,
    eventClient: .live,
    backgroundQueue: .main,
    mainQueue: .main,
    userDefaults: .live(),
    idfaClient: .live
  )

  public static let happyPath: EventsEnvironment = .init(
    pathMonitorClient: .satisfied,
    locationManager: .live,
    eventClient: .happyPath,
    backgroundQueue: .immediate,
    mainQueue: .immediate,
    userDefaults: .noop,
    idfaClient: .authorized
  )
}
