//
//  EventDetailsOverlayView.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import AsyncImageLoder
import ComposableArchitecture
import ComposableArchitectureHelpers
import HTTPRequestKit
import MapKit
import SharedModels
import SwiftUI
import SwiftUIExtension

struct EventDetailsOverlayView: View {
  @Environment(\.colorScheme) var colorScheme

  public init(store: Store<EventDetailsOverlayState, EventDetailsOverlayAction>) {
    self.store = store
  }

  public let store: Store<EventDetailsOverlayState, EventDetailsOverlayAction>

  @ViewBuilder var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: EventDetailsOverlayAction.view)) {
      viewStore in
      ZStack {
        VStack(alignment: .trailing) {
          Button(
            action: {
              if viewStore.isMember {
                viewStore.send(.startChat(true))
              } else if !viewStore.isMember, !viewStore.state.isAdmin {
                viewStore.send(.askJoinRequest(true))
              }
            },
            label: {
              Text(!viewStore.isMember && !viewStore.state.isAdmin ? "Join" : "Start Chat")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .padding(20)
            }
          )
          .frame(height: 50, alignment: .leading)
          .overlay(
            Capsule(style: .continuous).stroke(Color.white, lineWidth: 1.5)
          )

          Text(viewStore.event.name)
            .lineLimit(2)
            .font(.system(size: 31, weight: .light, design: .rounded))
            .padding(.top, 5)
            .foregroundColor(Color.white)

          Text("Created by: " + viewStore.conversationOwnerName)
            .lineLimit(1)
            .font(.system(size: 17, weight: .light, design: .rounded))
            .foregroundColor(Color.white)

          Text(viewStore.event.addressName)
            .font(.system(size: 17, weight: .light, design: .rounded))
            .lineLimit(2)
            .foregroundColor(Color.white)
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .padding(5)
    }
  }
}

extension EventDetailsOverlayView {
  public struct ViewState: Equatable {
    public var alert: AlertState<EventDetailsOverlayAction>?
    public var event: EventResponse.Item
    public var conversation: ConversationResponse.Item?
    public var conversationOwnerName: String = ""
    public var isMember: Bool = false
    public var isAdmin: Bool = false
    public var isMovingChatRoom: Bool = false
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case startChat(Bool)
    case askJoinRequest(Bool)
    case joinToEvent(Result<ConversationResponse.UserAdd, HTTPRequest.HRError>)
    case conversationResponse(Result<ConversationResponse.Item, HTTPRequest.HRError>)
  }
}

extension UIColor {
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      self.setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}
