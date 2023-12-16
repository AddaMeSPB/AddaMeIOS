//
//  HangoutDetailsOverlayView.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import AsyncImageLoder
import ComposableArchitecture
import ComposableArchitectureHelpers

import MapKit
import AddaSharedModels
import SwiftUI
import SwiftUIExtension

struct HangoutDetailsOverlayView: View {
    @Environment(\.colorScheme) var colorScheme

    public init(store: Store<HangoutDetails.State, HangoutDetails.Action>) {
        self.store = store
    }

    public let store: Store<HangoutDetails.State, HangoutDetails.Action>

    @ViewBuilder
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) {
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
                        .shadow(color: .black, radius: 5)
                        .foregroundColor(Color.white)

                    Text("Created by: " + viewStore.conversationOwnerName)
                        .lineLimit(1)
                        .font(.system(size: 17, weight: .light, design: .rounded))
                        .foregroundColor(Color.white)
                        .shadow(color: .black, radius: 5)

                    Text(viewStore.event.addressName)
                        .font(.system(size: 17, weight: .light, design: .rounded))
                        .lineLimit(2)
                        .foregroundColor(Color.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            .padding(5)
        }
    }
}

struct HangoutDetailsOverlayView_Previews: PreviewProvider {

    static let store = Store(
        initialState: HangoutDetails.State.placeHolderEvent
    ) {
        HangoutDetails()
    }

    static var previews: some View {
        HangoutDetailsOverlayView(store: store)
    }
}

//extension HangoutDetailsView {
//  public struct ViewState: Equatable {
//    public var alert: AlertState<HangoutDetailsOverlayAction>?
//    public var event: EventResponse
//    public var conversation: ConversationOutPut?
//    public var conversationOwnerName: String = ""
//    public var isMember: Bool = false
//    public var isAdmin: Bool = false
//    public var isMovingChatRoom: Bool = false
//  }
//
//  public enum ViewAction: Equatable {
//    case onAppear
//    case alertDismissed
//    case startChat(Bool)
//    case askJoinRequest(Bool)
//    case joinToEvent(TaskResult<AddUser>)
//    case conversationResponse(TaskResult<ConversationOutPut>)
//  }
//}

extension UIColor {
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      self.setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}
