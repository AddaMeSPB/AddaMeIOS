//
//  EventAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation
import ComposableArchitecture
import AddaMeModels
import FuncNetworking
import MapKit
import ComposableCoreLocation

public enum EventsAction: Equatable {

  case alertDismissed
  case dismissEventDetails
//  case isPresentingEventForm
  case presentEventForm(Bool)
  case eventForm(EventFormAction)
  
  case fetchMoreEventIfNeeded(item: EventResponse.Item?)
  case fetchMyEvents
  case event(index: Int, action: EventAction)
  case fetachAddressFromCLLocation(_ cllocation: CLLocation? = nil)
  case addressResponse(Result<String, Never>)
  case eventsResponse(Result<EventResponse, HTTPError>)
  case myEventsResponse(Result<EventResponse, HTTPError>)
  case eventTapped(EventResponse.Item)
  
  case currentLocationButtonTapped
  case locationManager(LocationManager.Action)
  case popupSettings
  case dismissEvent
  case onAppear
}

public enum EventAction: Equatable {}


extension EventsAction {
  static func view(_ localAction: EventView.ViewAction) -> Self {
    switch localAction {
    
    case .alertDismissed:
      return .alertDismissed
    case .dismissEventDetails:
      return .dismissEventDetails

    case .presentEventForm(let bool):
      return .presentEventForm(bool)
    case .eventForm(let eventFormAction):
      return self.eventForm(eventFormAction)
    case .event(index: let index, action: let action):
      return .event(index: index, action: action)
    case .currentLocationButtonTapped:
      return .currentLocationButtonTapped
    case .locationManager(let loc):
      return .locationManager(loc)
    case .fetachAddressFromCLLocation(let cllocation):
      return .fetachAddressFromCLLocation(cllocation)
    case .addressResponse(let address):
      return.addressResponse(address)
    case .fetchMoreEventIfNeeded(let item):
    return .fetchMoreEventIfNeeded(item: item)
    case .fetchMyEvents:
      return fetchMyEvents
    case .eventsResponse(let results):
      return .eventsResponse(results)
    case .myEventsResponse(let results):
    return .myEventsResponse(results)
    case .eventTapped(let event):
      return eventTapped(event)
    case .popupSettings:
      return popupSettings
    case .dismissEvent:
      return .dismissEvent
    case .onAppear:
      return .onAppear
    }
  }
}
