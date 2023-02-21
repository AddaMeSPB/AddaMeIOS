//
//  EventsViewTests.swift
//  
//
//  Created by Saroar Khandoker on 14.09.2021.
//

import XCTest
import ComposableArchitecture
import ComposableCoreLocation

import KeychainService
import AddaSharedModels
import PathMonitorClient
import Combine
import CoreLocation
import MapKit

@testable import EventView
@testable import EventFormView

class EventsView: XCTestCase {
  let scheduler = DispatchQueue.test
  let data = Date(timeIntervalSince1970: 0)

  // swiftlint:disable function_body_length
  func testRequestLocation_Allow() {
    let state = EventsState.placeholderEvents

    let environment = EventsEnvironment(
      pathMonitorClient: .satisfied,
      locationManager: .failing,
      eventClient: .empty,
      backgroundQueue: scheduler.eraseToAnyScheduler(),
      mainQueue: scheduler.eraseToAnyScheduler(),
      userDefaults: .noop
    )

    let store = TestStore(
      initialState: state,
      reducer: eventReducer,
      environment: environment
    )

    var didRequestInUseAuthorization = false
    var didRequestLocation = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

    store.environment.locationManager.authorizationStatus = { .notDetermined }
    store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    store.environment.locationManager.locationServicesEnabled = { true }
    store.environment.locationManager.requestLocation = {
      .fireAndForget { didRequestLocation = true }
    }

    store.environment.locationManager.requestWhenInUseAuthorization = {
      .fireAndForget { didRequestInUseAuthorization = true }
    }

    let currentLocation = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 0),
      verticalAccuracy: 0
    )

    store.send(.onAppear)

    store.send(.currentLocationButtonTapped) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)

    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
    store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    XCTAssertTrue(didRequestLocation)

    // Simulate finding the user's current location
    locationManagerSubject.send(.didUpdateLocations([currentLocation]))
    store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
    }

    locationManagerSubject.send(completion: .finished)
  }

  // swiftlint:disable function_body_length
  func testFlow_Success_GetEvents() {

    let state = EventsState.placeholderEvents

    let environment = EventsEnvironment(
      pathMonitorClient: .satisfied,
      locationManager: .failing,
      eventClient: .happyPath,
      backgroundQueue: scheduler.eraseToAnyScheduler(),
      mainQueue: scheduler.eraseToAnyScheduler(),
      userDefaults: .noop
    )

    let store = TestStore(
      initialState: state,
      reducer: eventReducer,
      environment: environment
    )

    var didRequestInUseAuthorization = false
    var didRequestLocation = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

    store.environment.locationManager.authorizationStatus = { .notDetermined }
    store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    store.environment.locationManager.locationServicesEnabled = { true }
    store.environment.locationManager.requestLocation = {
      .fireAndForget { didRequestLocation = true }
    }

    store.environment.locationManager.requestWhenInUseAuthorization = {
      .fireAndForget { didRequestInUseAuthorization = true }
    }

    let currentLocation = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 0),
      verticalAccuracy: 0
    )

    store.send(.onAppear)

    store.send(.currentLocationButtonTapped) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)

    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
    scheduler.advance()
    store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    XCTAssertTrue(didRequestLocation)

    // Simulate finding the user's current location
    locationManagerSubject.send(.didUpdateLocations([currentLocation]))
    scheduler.advance()
    store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
    }

    locationManagerSubject.send(completion: .finished)

    scheduler.advance()
    store.send(.eventsResponse(.success(
      EventResponse(
        items: [
          .init(
            id: "5fbfe53675a93bda87c7cb10", name: "Cool :)", categories: "General",
            duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
            addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
            sponsored: false, overlay: false,
            coordinates: [60.020532228306031, 30.388014239849944], createdAt: data,
            updatedAt: data),
          .init(
            id: "5fbe8a8c8ba94be8a688324c", name: "Awesome 🤩 app", categories: "General",
            duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
            addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
            sponsored: false, overlay: false,
            coordinates: [60.020525506753494, 30.387988546891499], createdAt: data,
            updatedAt: data)
        ],
        metadata: .init(per: 2, total: 4, page: 1)
      )
    ))) {
      $0.waitingForUpdateLocation = false
      $0.canLoadMorePages = $0.events.count < 4
      $0.isLoadingPage = false
//      $0.currentPage += 1

      let events = (
        $0.events +
        [
          .init(
            id: "5fbfe53675a93bda87c7cb10", name: "Cool :)", categories: "General",
            duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
            addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
            sponsored: false, overlay: false,
            coordinates: [60.020532228306031, 30.388014239849944], createdAt: self.data,
            updatedAt: self.data),
          .init(
            id: "5fbe8a8c8ba94be8a688324c", name: "Awesome 🤩 app", categories: "General",
            duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
            addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
            sponsored: false, overlay: false,
            coordinates: [60.020525506753494, 30.387988546891499], createdAt: self.data,
            updatedAt: self.data)
        ]
      )
      $0.events = .init(uniqueElements: events)
    }
  }

}
