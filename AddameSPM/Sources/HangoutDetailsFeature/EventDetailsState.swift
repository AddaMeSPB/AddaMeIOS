//
//  HangoutDetailsState.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ChatView
import ComposableArchitecture
import MapKit
import MapView
import AddaSharedModels

extension HangoutDetails.State {
  var view: HangoutDetailsView.ViewState {
    HangoutDetailsView.ViewState(
      alert: alert,
      event: event,
      pointsOfInterest: pointsOfInterest,
      region: region,
      conversation: conversation,
      conversationMembers: conversationMembers,
      conversationAdmins: conversationAdmins,
      chatMembers: chatMembers,
      conversationOwnerName: conversationOwnerName,
      isMember: isMember,
      isAdmin: isAdmin,
      isMovingChatRoom: isMovingChatRoom
    )
  }
 }

extension HangoutDetails.State {
  public static let coordinate = CLLocationCoordinate2D(
    latitude: 60.00380571585201, longitude: 30.399472870547118
  )

  public static let event = EventResponse.bicyclingDraff

  public static let region = CoordinateRegion(
    center: coordinate,
    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
  )

  public static let placeHolderEvent = Self(

    event: event,
    pointsOfInterest: [.init(coordinate: coordinate, subtitle: "Awesome", title: "Cool")],
    region: region,
    chatMembers: 3
  )
 }
