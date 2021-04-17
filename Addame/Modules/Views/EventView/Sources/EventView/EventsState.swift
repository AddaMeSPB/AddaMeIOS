//
//  EventState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import AddaMeModels
import ComposableArchitecture
import ComposableCoreLocation
import MapKit

public struct EventsState: Equatable {
  public init(
    alert: AlertState<EventsAction>? = nil,
    isConnected: Bool = true,
    isLocationAuthorized: Bool = false,
    isRequestingCurrentLocation: Bool = false,
    waitingForUpdateLocation: Bool = true,
    isLoadingPage: Bool = false,
    canLoadMorePages: Bool = true,
    currentPage: Int = 1,
    fetchAddress: String = "",
    currentEventPlace: EventResponse.Item = EventResponse.Item.draff,
    location: Location? = nil,
    eventFormState: EventFormState? = nil,
    events: [EventResponse.Item] = [],
    myEvents: [EventResponse.Item] = [],
    eventDetails: EventResponse.Item? = nil
  ) {
    self.alert = alert
    self.isConnected = isConnected
    self.isLocationAuthorized = isLocationAuthorized
    self.isRequestingCurrentLocation = isRequestingCurrentLocation
    self.waitingForUpdateLocation = waitingForUpdateLocation
    self.isLoadingPage = isLoadingPage
    self.canLoadMorePages = canLoadMorePages
    self.currentPage = currentPage
    self.fetchAddress = fetchAddress
    self.currentEventPlace = currentEventPlace
    self.location = location
    self.eventFormState = eventFormState
    self.events = events
    self.myEvents = myEvents
    self.eventDetails = eventDetails
  }
  
  public var alert: AlertState<EventsAction>?
  public var isConnected = true
  public var isLocationAuthorized = false
  public var isRequestingCurrentLocation = false
  public var waitingForUpdateLocation = true
  public var isLoadingPage = false
  public var canLoadMorePages = true
  
  public var currentPage = 1
  public var fetchAddress = ""
  public var currentEventPlace = EventResponse.Item.draff
  public var location: Location?
  public var events: [EventResponse.Item] = []
  public var myEvents: [EventResponse.Item] = []
  public var eventDetails: EventResponse.Item?
  
  public var eventFormState: EventFormState?
}


extension EventsState {  
  var view: EventView.ViewState {
    EventView.ViewState(
      alert: self.alert,
      isConnected: self.isConnected,
      isLocationAuthorized: self.isLocationAuthorized,
      waitingForUpdateLocation: self.waitingForUpdateLocation,
      fetchAddress: self.fetchAddress,
      events: self.events,
      myEvents: self.myEvents,
      eventDetails: self.eventDetails,
      isLoadingPage: self.isLoadingPage,
      eventFormState: self.eventFormState
    )
  }
}

extension EventsState {

  public static let events = Self(
    isConnected: true,
    isLocationAuthorized: true,
    waitingForUpdateLocation: false,
    isLoadingPage: true,
    location: Location(coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944)),
    events: [
      .init(id: "5fbfe53675a93bda87c7cb16", name: "Cool :)", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(), updatedAt: Date() ),
      .init(id: "5fbe8a8c8ba94be8a688324a", name: "Awesome 🤩 app", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020525506753494, 30.387988546891499], createdAt: Date(), updatedAt: Date()),
      .init(id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.00380571585201, 30.399472870547118], createdAt: Date(), updatedAt: Date()),
      .init(id: "5fbea245b226053f0ece711c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany", imageUrl: "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия", type: "Point", sponsored: false, overlay: false, coordinates: [60.261340452875721, 29.873706166262373], createdAt: Date(), updatedAt: Date())
    ]
  )
}
