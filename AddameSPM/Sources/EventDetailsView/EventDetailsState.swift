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
import AddaSharedModels

// public struct EventDetailsState: Equatable {
//    public init(
//        alert: AlertState<EventDetailsAction>? = nil,
//        event: EventResponse,
//        pointsOfInterest: [PointOfInterest] = [],
//        region: CoordinateRegion? = nil,
//        conversation: ConversationOutPut? = nil,
//        conversationMembers: [UserOutput] = [],
//        conversationAdmins: [UserOutput] = [],
//        chatMembers: Int = 0,
//        eventDetailsOverlayState: EventDetailsOverlayState
//    ) {
//        self.alert = alert
//        self.event = event
//        self.pointsOfInterest = pointsOfInterest
//        self.region = region
//        self.conversation = conversation
//        self.conversationMembers = conversationMembers
//        self.conversationAdmins = conversationAdmins
//        self.chatMembers = chatMembers
//        self.eventDetailsOverlayState = eventDetailsOverlayState
//    }
//
//  public var alert: AlertState<EventDetailsAction>?
//  public let event: EventResponse
//  public var pointsOfInterest: [PointOfInterest] = []
//  public var region: CoordinateRegion?
//  public var conversation: ConversationOutPut?
//  public var conversationMembers: [UserOutput] = []
//  public var conversationAdmins: [UserOutput] = []
//  public var chatMembers: Int = 0
//  public var eventDetailsOverlayState: EventDetailsOverlayState
// }
//
// extension EventDetailsState {
//  var view: EventDetailsView.ViewState {
//    EventDetailsView.ViewState(
//      alert: alert,
//      event: event,
//      pointsOfInterest: pointsOfInterest,
//      region: region,
//      conversation: conversation,
//      conversationMembers: conversationMembers,
//      conversationAdmins: conversationAdmins,
//      chatMembers: chatMembers,
//      eventDetailsOverlayState: eventDetailsOverlayState
//    )
//  }
// }
//
// extension EventDetailsState {
//  public static let coordinate = CLLocationCoordinate2D(
//    latitude: 60.00380571585201, longitude: 30.399472870547118
//  )
//
//    public static let event = EventResponse.bicyclingDraff
//
//  public static let region = CoordinateRegion(
//    center: coordinate,
//    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
//  )
//
//  public static let placeHolderEvent = Self(
//    alert: nil,
//    event: event,
//    pointsOfInterest: [
//        .init(coordinate: coordinate, subtitle: event.addressName, title: event.name)
//    ],
//    region: region,
//    conversation: nil,
//    chatMembers: 3,
//    eventDetailsOverlayState: .init(alert: nil, event: event, conversation: nil)
//  )
// }
