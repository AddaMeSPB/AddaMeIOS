//
//  EventDetailsState.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ChatView
import ComposableArchitecture
import MapKit
import MapView
import SharedModels

public struct EventDetailsState: Equatable {
  public init(
    alert: AlertState<EventDetailsAction>? = nil,
    event: EventResponse.Item,
    pointsOfInterest: [PointOfInterest] = [],
    region: CoordinateRegion? = nil,
    conversation: ConversationResponse.Item? = nil,
    chatMembers: Int = 0,
    eventDetailsOverlayState: EventDetailsOverlayState
  ) {
    self.alert = alert
    self.event = event
    self.pointsOfInterest = pointsOfInterest
    self.region = region
    self.conversation = conversation
    self.chatMembers = chatMembers
    self.eventDetailsOverlayState = eventDetailsOverlayState
  }

  public var alert: AlertState<EventDetailsAction>?
  public let event: EventResponse.Item
  public var pointsOfInterest: [PointOfInterest] = []
  public var region: CoordinateRegion?
  public var conversation: ConversationResponse.Item?
  public var chatMembers: Int = 0
  public var eventDetailsOverlayState: EventDetailsOverlayState
}

extension EventDetailsState {
  var view: EventDetailsView.ViewState {
    EventDetailsView.ViewState(
      alert: alert,
      event: event,
      pointsOfInterest: pointsOfInterest,
      region: region,
      conversation: conversation,
      chatMembers: chatMembers,
      eventDetailsOverlayState: eventDetailsOverlayState
    )
  }
}

extension EventDetailsState {
  public static let coordinate = CLLocationCoordinate2D(
    latitude: 60.00380571585201, longitude: 30.399472870547118
  )

  public static let event = EventResponse.Item(
    id: "5fbea245b226053f0ece711c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany",
    imageUrl:
      "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
    duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
    addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия",
    type: "Point", sponsored: false, overlay: false,
    coordinates: [60.261340452875721, 29.873706166262373],
    createdAt: Date(), updatedAt: Date()
  )

  public static let region = CoordinateRegion(
    center: coordinate,
    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
  )

  public static let placeHolderEvent = Self(
    alert: nil,
    event: event,
    pointsOfInterest: [
      .init(coordinate: coordinate, subtitle: event.addressName, title: "Bicycling 🚴🏽")
    ],
    region: region,
    conversation: nil,
    chatMembers: 3,
    eventDetailsOverlayState: .init(alert: nil, event: event, conversation: nil)
  )
}
