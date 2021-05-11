//
//  EventDetailsView.swift
//  
//
//  Created by Saroar Khandoker on 13.04.2021.
//

import ComposableArchitecture
import SwiftUI
import SharedModels
import HttpRequest
import MapKit
import ComposableCoreLocation
import AsyncImageLoder
import SwiftUIExtension


public struct EventDetailsView: View {

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) private var presentationMode
  
  public let event:  EventResponse.Item
  
  public init(event: EventResponse.Item) {
    self.event = event
  }

  @ViewBuilder public var body: some View {
    ScrollView {
      VStack() {
        ZStack {
          if event.imageUrl != nil {
            AsyncImage(
              urlString: event.imageUrl,
              placeholder: {
                Text("Loading...").frame(width: 100, height: 100, alignment: .center)
              },
              image: {
                Image(uiImage: $0).resizable()
              }
            )
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.top)
//            .overlay(
//              EventDetailOverlay(event: event, conversation: conversationViewModel.conversation, startChat: self.$startChat, askJoinRequest: self.$askJoinRequest).environmentObject(conversationViewModel),
//              alignment: .bottomTrailing
//            )
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
            Image(systemName: "photo")
              .font(.system(size: 200, weight: .medium))
              .frame(width: 450, height: 350)
              .foregroundColor(Color.backgroundColor(for: self.colorScheme))
//              .overlay(
//                EventDetailOverlay(event: event, conversation: conversationViewModel.conversation, startChat: self.$startChat, askJoinRequest: self.$askJoinRequest).environmentObject(conversationViewModel),
//                alignment: .bottomTrailing
//              )
              .overlay(
                Button {
                  presentationMode.wrappedValue.dismiss()
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .frame(width: 60, height: 60, alignment: .center)
                }
                .padding([.top, .trailing], 40),
                alignment: .topTrailing
              )
          }
          
        }
        
        Text("Event Members:")
          .font(.title)
          .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
          .lineLimit(2)
          .minimumScaleFactor(0.5)
          .alignmentGuide(.leading) { d in d[.leading] }
          .font(.system(size: 23, weight: .light, design: .rounded))
        Divider()
          .padding(.bottom, -10)
        
        ScrollView {
//          LazyVGrid(columns: columns, spacing: 10) {
//            ForEach( conversationViewModel.conversation.members?.uniqElemets() ?? []) { member in
//              VStack(alignment: .leading) {
//
//                AsyncImage(
//                  urlString: member.avatarUrl,
//                  placeholder: {
//                    Text("Loading...").frame(width: 100, height: 100, alignment: .center)
//                  },
//                  image: {
//                    Image(uiImage: $0).resizable()
//                  }
//                )
//                .aspectRatio(contentMode: .fit)
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
//                .clipShape(Circle())
//                .padding()
//
//                Text("\(member.fullName)")
//                  .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//                  .lineLimit(1)
//                  .alignmentGuide(.leading) { d in d[.leading] }
//                  .font(.system(size: 15, weight: .light, design: .rounded))
//                Spacer()
//              }
//              .padding()
//
//            }
//          }
        }
        
        // Spacer()
        Divider()
        VStack(alignment: .leading) {
          Text("Event Location:")
            .font(.title)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .alignmentGuide(.leading) { d in d[.leading] }
            .font(.system(size: 23, weight: .light, design: .rounded))
            .padding()
        }
        
//        MapView(place: event, places: [event], isEventDetailsView: true)
//          .frame(height: 400)
//          .padding(.bottom, 20)
        
      }
    }
    .edgesIgnoringSafeArea(.top)
    .edgesIgnoringSafeArea(.bottom)
    .background(Color(.systemBackground))
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    EventDetailsView(event: .draff)
  }
}
