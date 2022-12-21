 import AsyncImageLoder
 import ChatView
 import ComposableArchitecture
 import ComposableArchitectureHelpers
 import ComposableCoreLocation
 import MapKit
 import AddaSharedModels
 import SwiftUI
 import SwiftUIExtension
 import FoundationExtension

public enum EventAction: Equatable {}

 public struct EventRowView: View {
  let currentLocation: Location?
  @Environment(\.colorScheme) var colorScheme

  public let store: Store<EventResponse, EventAction>

  public init(
    store: Store<EventResponse, EventAction>,
    currentLocation: Location?
  ) {
    self.currentLocation = currentLocation
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        if viewStore.imageUrl != nil {
          AsyncImage(
            url: viewStore.imageUrl!.url,
            placeholder: { Text("Loading...").frame(width: 100, height: 100, alignment: .center) },
            image: {
              Image(uiImage: $0).resizable()
            }
          )
          .aspectRatio(contentMode: .fit)
          .frame(width: 120)
          .padding(.trailing, 15)
          .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
        } else {
          Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 90)
            .padding(10)
            .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
        }

        VStack(alignment: .leading) {
          Text(viewStore.name)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .lineLimit(2)
            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
            .font(.system(size: 23, weight: .light, design: .rounded))
            .padding(.top, 10)
            .padding(.bottom, 5)

          Text(viewStore.addressName)
            .lineLimit(2)
            .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
            .font(.system(size: 15, weight: .light, design: .rounded))
            .foregroundColor(.blue)
            .padding(.bottom, 5)

          Spacer()
          HStack {
            Spacer()
            Text(" \(viewStore.distance?.meterTOmiles ?? "0.0")")
              .lineLimit(2)
              .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
              .font(.system(size: 15, weight: .light, design: .rounded))
              .foregroundColor(.blue)
              .padding(.bottom, 10)
          }
          .padding(.bottom, 5)
        }

        Spacer()
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(
            colorScheme == .dark
              ? Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
              : Color(
                #colorLiteral(
                  red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)))
      )
      .padding([.leading, .trailing], 10)
      .padding([.top, .bottom], 5)
    }
  }
 }

 extension Double {
  var meterTOkilometers: String {
    return String(format: "%.02f km away", self / 1000)
  }

  var meterTOmiles: String {
    return String(format: "%.02f miles away", self / 1609)
  }
 }

// struct EventRowView_Previews: PreviewProvider {
//
//  static let store: Store<EventResponse., EventAction> = .init(
//    initialState: EventsState.event,
//    reducer: eventsReducer,
//    environment: EventsEnvironment.happyPath
//  )
//
//  static var previews: some View {
//    EventRowView(store: store, currentLocation: EventsState.eventForRow.location)
//  }
// }
