//
//  EventReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Combine
import ComposableArchitecture
import SwiftUI
import MapKit
import AddaMeModels
import FuncNetworking

struct Foo {
  @AppStorage("isAuthorized")
  public static var isAuthorized: Bool = false
}

public let eventReducer = Reducer<EventsState, EventsAction, EventsEnvironment> { state, action, environment in
    struct LocationManagerId: Hashable {}
    
    func fetchMoreEventIfNeeded() -> Effect<EventsAction, Never>  {
      guard state.isConnected, let location = state.location else { return .none }
      state.location = location
//      self.fetchMoreEventIfNeeded()
//      self.fetchAddress(location)
      
      let distance = UserDefaults.standard.double(forKey: "distance") == 0.0 ? 250.0 : UserDefaults.standard.double(forKey: "distance")
      
      let lat = "\(location.coordinate.latitude)"
      let long = "\(location.coordinate.longitude)"
      
      guard !state.isLoadingPage && state.canLoadMorePages else { return .none }
      
      state.isLoadingPage = true

      let query = QueryItem(page: "\(state.currentPage)", per: "10", lat: lat, long: long, distance: "\(Int(distance))" )
      
      return environment.eventClient.events(query, "")
        .retry(3)
        .receive(on: environment.mainQueue.animation(.default))
        .removeDuplicates()
        .catchToEffect()
        .map(EventsAction.eventsResponse)
    }
    
    func fetchMoreMyEvents() -> Effect<EventsAction, Never> {
      
      guard !state.isLoadingPage && state.canLoadMorePages else { return .none }
      
      state.isLoadingPage = true
          
      let query = QueryItem(page: "\(state.currentPage)", per: "10")
      
      return environment.eventClient.events(query, "my")
        .retry(3)
        .receive(on: environment.mainQueue.animation(.default))
        .removeDuplicates()
        .catchToEffect()
        .map(EventsAction.myEventsResponse)
    }
    
    switch action {
    
    case let .presentEventForm(present):
      state.eventFormState = present ? EventFormState() : nil
      return .none

    case .dismissEvent:
      
      return .none
  
    case .onAppear:
            
      return .merge(
        environment.locationManager
          .create(id: LocationManagerId())
          .map(EventsAction.locationManager),

        environment.locationManager
          .requestWhenInUseAuthorization(id: LocationManagerId())
          .fireAndForget()
      )
      
    case .alertDismissed:
      state.alert = nil
      return .none
      
    case .fetchMoreEventIfNeeded(let item):
  
      guard let item = item else {
        return fetchMoreEventIfNeeded()
      }
      
      let threshouldIndex = state.events.index(state.events.endIndex, offsetBy: -7)
      if state.events.firstIndex(where: { $0.id == item.id }) == threshouldIndex {
        return fetchMoreEventIfNeeded()
      }

      return .none
      
    case .fetchMyEvents:
      // move inside .locationManager(.didUpdateLocations(locations)):
      return fetchMoreMyEvents()

    case .event(index: let index):
      
      return .none
    case .eventsResponse(.success(let eventArray)):

      state.waitingForUpdateLocation = false
      state.canLoadMorePages = state.events.count < eventArray.metadata.total
      state.isLoadingPage = false
      state.currentPage += 1
          
      state.events = (state.events + eventArray.items)
      return .none
      
    case .eventsResponse(.failure(let error)):
      state.isLoadingPage = false
      state.alert = .init(title: TextState(error.description))
      
      return .none
    
    case .myEventsResponse(.success(let events)):
      
      state.waitingForUpdateLocation = false
      state.canLoadMorePages = state.events.count < events.metadata.total
      state.isLoadingPage = false
      state.currentPage += 1
          
      state.myEvents = (state.myEvents + events.items)
      
      return.none
      
    case .myEventsResponse(.failure(let error)):
      
      state.alert = .init(
        title: TextState("fetch my event error")
      )
      
      print(#line )
      
      return .none
      
    case .eventTapped(let event):
      state.eventDetails = event
      return .none
      
    case .fetachAddressFromCLLocation(let cllocation):
      
      return .none
      
    case .addressResponse(.success(let address)):
      
      return .none
      
    case .locationManager(.didChangeAuthorization(.authorizedAlways)),
         .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):

      state.isLocationAuthorized = true
      state.isConnected = true
      
      return environment.locationManager
        .requestLocation(id: LocationManagerId())
        .fireAndForget()
      
    case .locationManager(.didChangeAuthorization(.denied)),
         .locationManager(.didChangeAuthorization(.restricted)):
      
      state.isLocationAuthorized = false
      state.isConnected = false

      state.alert = .init(
        title: TextState("Please give us access to your location so you can use our full features"),
        message: TextState("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel(TextState("Cancel"), send: .alertDismissed),
        secondaryButton: .default(TextState("Go Settings"), send: .popupSettings)
      )
      
      return .none
      
    case let .locationManager(.didUpdateLocations(locations)):
      print(#line, locations)
      guard state.isConnected, let location = locations.first else { return .none }
      state.location = location
//      self.fetchMoreEventIfNeeded()
//      self.fetchAddress(location)
      
      return fetchMoreEventIfNeeded()
      
    case .locationManager(.didChangeAuthorization(.notDetermined)):
      return .none
    case .locationManager(.didChangeAuthorization( let status)):
      print(#line, status)
      return .none
    case .locationManager(.didDetermineState(_, region: let region)):
      return .none
    case .locationManager(.didEnterRegion(_)):
      return .none
    case .locationManager(.didExitRegion(_)):
      return .none
    case .locationManager(.didFailRanging(beaconConstraint: let beaconConstraint, error: let error)):
      return .none
    case .locationManager(.didFailWithError(_)):
      return .none
    case .locationManager(.didFinishDeferredUpdatesWithError(_)):
      return .none
    case .locationManager(.didPauseLocationUpdates):
      return .none
    case .locationManager(.didResumeLocationUpdates):
      return .none
    case .locationManager(.didStartMonitoring(region: let region)):
      return .none
    case .locationManager(.didUpdateHeading(newHeading: let newHeading)):
      return .none
    case .locationManager(.didUpdateTo(newLocation: let newLocation, oldLocation: let oldLocation)):
      return .none
    case .locationManager(.didVisit(_)):
      return .none
    case .locationManager(.monitoringDidFail(region: let region, error: let error)):
      return .none
    case .locationManager(.didRangeBeacons(_, satisfyingConstraint: let satisfyingConstraint)):
      return .none
    case .currentLocationButtonTapped:
      
      guard environment.locationManager.locationServicesEnabled() else {
        state.alert = .init(title: TextState("Location services are turned off."))
        state.waitingForUpdateLocation = false
        return .none
      }

      switch environment.locationManager.authorizationStatus() {
      case .notDetermined:
        state.isRequestingCurrentLocation = true
        state.waitingForUpdateLocation = false
        #if os(macOS)
          return environment.locationManager
            .requestAlwaysAuthorization(id: LocationManagerId())
            .fireAndForget()
        #else
          return environment.locationManager
            .requestWhenInUseAuthorization(id: LocationManagerId())
            .fireAndForget()
        #endif

      case .restricted:
        state.alert = .init(
          title: TextState("Please give us access to your location in settings"),
          message: TextState("Please go to Settings and turn on the permissions"),
          primaryButton: .cancel(TextState("Cancel"), send: .alertDismissed),
          secondaryButton: .default(TextState(""), send: .popupSettings)
        )

        state.waitingForUpdateLocation = false
        return .none

      case .denied:
        state.alert = .init(
          title: TextState("Please give us access to your location in settings"),
          message: TextState("Please go to Settings and turn on the permissions"),
          primaryButton: .cancel( TextState("Cancel"), send: .alertDismissed),
          secondaryButton: .default(TextState(""), send: .popupSettings)
        )
        state.waitingForUpdateLocation = false
        return .none

      case .authorizedAlways, .authorizedWhenInUse:
        state.isLocationAuthorized = true
        state.isConnected = true
        state.waitingForUpdateLocation = false
        
        return environment.locationManager
          .requestLocation(id: LocationManagerId())
          .fireAndForget()

      @unknown default:
        return .none
      }
      
    case .popupSettings:
      if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      
      return .none
    case .dismissEventDetails:
      state.eventDetails = nil
      return .none
  
    case .eventForm(_):
      
      return .none
    }
  }

