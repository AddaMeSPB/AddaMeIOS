//
//  EventRowView.swift
//  
//
//  Created by Saroar Khandoker on 15.04.2021.
//

import ComposableArchitecture
import SwiftUI
import AsyncImageLoder
import AddaMeModels

//public struct EventRowView: View {
//  
//  @Environment(\.colorScheme) var colorScheme
//  
//  public init(store: Store<EventResponse.Item, MyEventAction>) {
//    self.store = store
//  }
//  
//  public let store: Store<EventResponse.Item, MyEventAction>
//  
//  public var body: some View {
//    WithViewStore(self.store) { viewStore in
//      HStack {
//        if viewStore.imageUrl != nil {
//          AsyncImage(
//            urlString: viewStore.imageUrl,
//            placeholder: { Text("Loading...").frame(width: 100, height: 100, alignment: .center) },
//            image: {
//              Image(uiImage: $0).resizable()
//            }
//          )
//          .aspectRatio(contentMode: .fit)
//          .frame(width: 120)
//          .padding(.trailing, 15)
//          .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
//        } else {
//          Image(systemName: "photo")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 90)
//            .padding(10)
//            .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
//        }
//        
//        VStack(alignment: .leading) {
//          Text(viewStore.name)
//            .foregroundColor(colorScheme  == .dark ? Color.white : Color.black)
//            .lineLimit(2)
//            .alignmentGuide(.leading) { d in d[.leading] }
//            .font(.system(size: 23, weight: .light, design: .rounded))
//            .padding(.top, 10)
//            .padding(.bottom, 5)
//          
//          Text(viewStore.addressName)
//            .lineLimit(2)
//            .alignmentGuide(.leading) { d in d[.leading] }
//            .font(.system(size: 15, weight: .light, design: .rounded))
//            .foregroundColor(.blue)
//            .padding(.bottom, 5)
//        }
//        
//        Spacer()
//      }
//      .background(
//        RoundedRectangle(cornerRadius: 10)
//          .foregroundColor(colorScheme == .dark ? Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)) : Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)) )
//      )
//      .padding(10)
//      .padding([.leading, .trailing], 10)
//    }
//  }
//  
//}
