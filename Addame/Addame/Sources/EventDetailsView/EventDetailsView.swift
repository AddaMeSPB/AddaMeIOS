//
//  EventDetailsView.swift
//  
//
//  Created by Saroar Khandoker on 05.07.2021.
//

import ComposableArchitecture
import SwiftUI
import MapKit

import SharedModels
import HttpRequest

import ComposableCoreLocation
import AsyncImageLoder
import SwiftUIExtension
import ComposableArchitectureHelpers
import MapView
import ConversationClient
import KeychainService
import ChatView

public struct EventDetailsView: View {

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) private var presentationMode

  private let columns = [
    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
  ]

  public init(store: Store<EventDetailsState, EventDetailsAction>) {
    self.store = store
  }

  public let store: Store<EventDetailsState, EventDetailsAction>

  @ViewBuilder public var body: some View {
    WithViewStore(self.store.scope(state: { $0.view }, action: EventDetailsAction.view)) { viewStore in

      ScrollView {
        VStack {

          if viewStore.event.imageUrl != nil {
            AsyncImage(
              urlString: viewStore.event.imageUrl,
              placeholder: {
                ProgressView()
                  .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height / 2.3,
                    alignment: .center
                  )
                  .background(Color.gray)
              },
              image: {
                Image(uiImage: $0).resizable()
              }
            )
            .padding(.bottom, 20)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.top)
            .overlay(
              EventDetailsOverlayView(store: self.store.scope(
                  state: \.eventDetailsOverlayState,
                  action: EventDetailsAction.eventDetailsOverlay
                )
              )
              .padding(.bottom, 25),
              alignment: .bottomTrailing
            )
            .overlay(
                Button {
                  presentationMode.wrappedValue.dismiss()
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .frame(width: 60, height: 60, alignment: .center)
                }
                .padding([.top, .trailing], 10),
                alignment: .topTrailing
              )

          } else {

            Image(uiImage: UIColor.blue.image(
              CGSize(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height / 2.3)
              )
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.bottom, 20)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.top)
            .overlay(
              EventDetailsOverlayView(store: self.store.scope(
                  state: \.eventDetailsOverlayState,
                  action: EventDetailsAction.eventDetailsOverlay
                )
              )
              .padding(.bottom, 25),
              alignment: .bottomTrailing
            )
            .overlay(
                Button {
                  presentationMode.wrappedValue.dismiss()
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .frame(width: 60, height: 60, alignment: .center)
                }
                .padding([.top, .trailing], 10),
                alignment: .topTrailing
              )

          }

          Text("Event friends: \(viewStore.chatMembers)")
            .font(.title)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
            .font(.system(size: 23, weight: .light, design: .rounded))
          Divider()
            .padding(.bottom, -10)

          ScrollView {
              LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewStore.conversation?.members?.uniqElemets() ?? []) { member in
                  VStack(alignment: .leading) {

                    if member.avatarUrl != nil {
                      AsyncImage(
                        urlString: member.avatarUrl,
                        placeholder: {
                          ProgressView()
                        },
                        image: {
                          Image(uiImage: $0).resizable()
                        }
                      )
                      .aspectRatio(contentMode: .fit)
                      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                      .clipShape(Circle())
                      .padding()
                    } else {
                      Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .clipShape(Circle())
                        .padding()
                    }

                    Text("\(member.fullName)")
                      .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                      .lineLimit(1)
//                      .alignmentGuide(.center)
                      // { viewDimensions in viewDimensions[.leading] }
                      .font(.system(size: 15, weight: .light, design: .rounded))
                    Spacer()
                  }
                  .padding()

                }
              }
          }

          Spacer()
          Divider()
          VStack(alignment: .leading) {
            Text("Event Location:")
              .font(.title)
              .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
              .lineLimit(2)
              .minimumScaleFactor(0.5)
              .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
              .font(.system(size: 23, weight: .light, design: .rounded))
              .padding()
          }

          MapView(
            pointsOfInterest: viewStore.pointsOfInterest,
            region: viewStore.binding(
              get: { $0.region },
              send: EventDetailsView.ViewAction.updateRegion
            ),
            isEventDetailsView: true
          )
          .edgesIgnoringSafeArea([.all])
          .frame(height: 400)
          .padding(.bottom, 20)

        } // VStack
      } // ScrollView
      .background(Color(.systemBackground))

    }
    .onAppear {
      ViewStore(store.stateless).send(.onAppear)
    }

  }

}

extension EventDetailsView {

  public struct ViewState: Equatable {
    public var alert: AlertState<EventDetailsAction>?
    public let event: EventResponse.Item
    public var pointsOfInterest: [PointOfInterest] = []
    public var region: CoordinateRegion?
    public var conversation: ConversationResponse.Item?
    public var chatMembers: Int = 0
    public var eventDetailsOverlayState: EventDetailsOverlayState
  }

  public enum ViewAction: Equatable {
    case onAppear
    case alertDismissed
    case moveToChatRoom(Bool)
    case updateRegion(CoordinateRegion?)
    case eventDetailsOverlay(EventDetailsOverlayAction)
  }

}

struct EventDetailsView_Previews: PreviewProvider {

  static let environment = EventDetailsEnvironment(
    conversationClient: ConversationClient.happyPath,
    mainQueue: .immediate
  )

  static let store = Store(
    initialState: EventDetailsState.placeHolderEvent,
    reducer: eventDetailsReducer,
    environment: environment
  )

  static var previews: some View {
    TabView {
//      NavigationView {
        EventDetailsView(store: store)
//          .redacted(reason: .placeholder)
//          .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
//          .environment(\.colorScheme, .dark)
//      }
    }
//
//    Group {
//      TabView {
//        NavigationView {
//          EventView(store: store)
//  //          .redacted(reason: .placeholder)
//        }
//      }
//      TabView {
//        NavigationView {
//          EventView(store: store)
//  //          .redacted(reason: .placeholder)
//            .environment(\.colorScheme, .dark)
//        }
//      }
//    }
  }
}
