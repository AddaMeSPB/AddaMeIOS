//
//  EventDetailOverlayState.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import MapKit
import MapView
import SharedModels

public struct EventDetailsOverlayState: Equatable {
  public init(
    alert: AlertState<EventDetailsOverlayAction>?,
    event: EventResponse.Item,
    conversation: ConversationResponse.Item? = nil,
    isMember: Bool = false,
    isAdmin: Bool = false,
    isMovingChatRoom: Bool = false
  ) {
    self.alert = alert
    self.event = event
    self.conversation = conversation
    self.isMember = isMember
    self.isAdmin = isAdmin
    self.isMovingChatRoom = isMovingChatRoom
  }

  public var alert: AlertState<EventDetailsOverlayAction>?
  public var event: EventResponse.Item
  public var conversation: ConversationResponse.Item?
  public var conversationOwnerName: String = ""
  public var isMember: Bool = false
  public var isAdmin: Bool = false
  public var isMovingChatRoom: Bool = false
}

extension EventDetailsOverlayState {
  var view: EventDetailsOverlayView.ViewState {
    EventDetailsOverlayView.ViewState(
      alert: alert,
      event: event,
      conversation: conversation,
      conversationOwnerName: conversationOwnerName,
      isMember: isMember,
      isAdmin: isAdmin,
      isMovingChatRoom: isMovingChatRoom
    )
  }
}
