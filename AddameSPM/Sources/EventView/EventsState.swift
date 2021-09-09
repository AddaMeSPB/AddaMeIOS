//
//  EventState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ChatView
import ComposableArchitecture
import ComposableCoreLocation
import EventDetailsView
import EventFormView
import MapKit
import SharedModels

public struct EventsState: Equatable {

  public var alert: AlertState<EventsAction>?
  public var isConnected = true
  public var isLocationAuthorized = false
  public var isRequestingCurrentLocation = false
  public var waitingForUpdateLocation = true
  public var isLoadingPage = false
  public var canLoadMorePages = true
  public var isMovingChatRoom: Bool = false
  public var isEFromNavigationActive = false

  public var currentPage = 1
  public var currentAddress = ""
  public var placeMark: CLPlacemark?
  public var location: Location?
  public var events: IdentifiedArrayOf<EventResponse.Item> = []
  public var myEvents: IdentifiedArrayOf<EventResponse.Item> = []
  public var event: EventResponse.Item?
  public var conversation: ConversationResponse.Item?

  public var eventFormState: EventFormState?
  public var eventDetailsState: EventDetailsState?
  public var chatState: ChatState?

  public var isEventDetailsSheetPresented: Bool { eventDetailsState != nil }

  public init(
    alert: AlertState<EventsAction>? = nil, isConnected: Bool = true,
    isLocationAuthorized: Bool = false, isRequestingCurrentLocation: Bool = false,
    waitingForUpdateLocation: Bool = true,
    isMovingChatRoom: Bool = false,
    isEFromNavigationActive: Bool = false,
    isLoadingPage: Bool = false,
    canLoadMorePages: Bool = true, currentPage: Int = 1,
    currentAddress: String = "", placeMark: CLPlacemark? = nil,
    location: Location? = nil, events: IdentifiedArrayOf<EventResponse.Item> = [],
    myEvents: IdentifiedArrayOf<EventResponse.Item> = [], event: EventResponse.Item? = nil,
    eventFormState: EventFormState? = nil,
    eventDetailsState: EventDetailsState? = nil,
    chatState: ChatState? = nil
  ) {
    self.alert = alert
    self.isConnected = isConnected
    self.isLocationAuthorized = isLocationAuthorized
    self.isRequestingCurrentLocation = isRequestingCurrentLocation
    self.waitingForUpdateLocation = waitingForUpdateLocation
    self.isLoadingPage = isLoadingPage
    self.canLoadMorePages = canLoadMorePages
    self.isMovingChatRoom = isMovingChatRoom
    self.isEFromNavigationActive = isEFromNavigationActive
    self.currentPage = currentPage
    self.currentAddress = currentAddress
    self.placeMark = placeMark
    self.location = location
    self.events = events
    self.myEvents = myEvents
    self.event = event
    self.eventFormState = eventFormState
    self.eventDetailsState = eventDetailsState
    self.chatState = chatState
  }

}

extension EventsState {
  var view: EventView.ViewState {
    EventView.ViewState(
      alert: alert, isConnected: isConnected,
      isLocationAuthorized: isLocationAuthorized,
      waitingForUpdateLocation: waitingForUpdateLocation,
      isLoadingPage: isLoadingPage, isMovingChatRoom: isMovingChatRoom,
      location: location,
      events: events, myEvents: myEvents,
      event: event,
      placeMark: placeMark,
      eventFormState: eventFormState,
      eventDetailsState: eventDetailsState,
      chatState: chatState,
      conversation: conversation
    )
  }
}

// swiftlint:disable all
extension EventsState {

  public static let event: EventResponse.Item = .init(
    id: "5fbfe53675a93bda87c7cb16",
    name: "Cool :)", categories: "General",
    imageUrl:
      "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
    duration: 14400,
    isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
    addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false,
    overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(),
    updatedAt: Date()
  )

  private static let events: IdentifiedArrayOf<EventResponse.Item> = [
    .init(
      id: "5fbfe53675a93bda87c7cb16",
      name: "Cool :)", categories: "General",
      imageUrl:
        "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
      duration: 14400,
      isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
      addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false,
      overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(),
      updatedAt: Date()),
    .init(
      id: "5fbe8a8c8ba94be8a688324b", name: "Awesome 🤩 app", categories: "General",
      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
      addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false,
      overlay: false, coordinates: [60.020525506753494, 30.387988546891499], createdAt: Date(),
      updatedAt: Date()),
    .init(
      id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany",
      imageUrl:
        "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
      addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point",
      sponsored: false, overlay: false, coordinates: [60.00380571585201, 30.399472870547118],
      createdAt: Date(), updatedAt: Date()),
    .init(
      id: "5fbea245b226053f0ece712c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany",
      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
      addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия",
      type: "Point", sponsored: false, overlay: false,
      coordinates: [60.261340452875721, 29.873706166262373], createdAt: Date(), updatedAt: Date()),
  ]

  public static let placeholderEvents = Self(
    isConnected: true,
    isLocationAuthorized: true,
    waitingForUpdateLocation: false,
    isLoadingPage: true,
    location: Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 0),
      verticalAccuracy: 0
    ),
    events: events
  )
  public static let fetchEvents = Self(
    isConnected: true,
    isLocationAuthorized: true,
    waitingForUpdateLocation: true,
    isLoadingPage: false,
    location: Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 0),
      verticalAccuracy: 0
    ),
    events: events
  )


  public static let eventForRow = Self(
    waitingForUpdateLocation: false,
    location: Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 0),
      verticalAccuracy: 0
    ),
    event: event
  )

}
