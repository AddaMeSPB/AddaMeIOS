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
import NukeUI


/// you can do that by select Reducer then click Command + Option + e
import Foundation
import ComposableArchitecture

public struct EventRowReducer: Reducer {
    public typealias State = EventResponse

    public enum Action: Equatable {}

    public init() {}

    public var body: some Reducer<State, Action> {

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {}
    }
}

public struct EventRowView: View {
    let currentLocation: Location?
    let geo: GeometryProxy
    @Environment(\.colorScheme) var colorScheme

    public let store: StoreOf<EventRowReducer>

    public init(
        store: StoreOf<EventRowReducer>,
        currentLocation: Location?,
        geo: GeometryProxy
    ) {
        self.currentLocation = currentLocation
        self.store = store
        self.geo = geo
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                HStack {
                    Group {
                        if let imageUrl = viewStore.imageUrl {
                            LazyImage(request: ImageRequest(url: imageUrl.url)) { state in
                                if let image = state.image {
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)

                                } else {
                                    Image(systemName: "person")
                                        .resizable()
                                        .padding(18)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }

                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .padding(18)
                                .aspectRatio(contentMode: .fill)

                        }
                    }
                    .frame(width: geo.size.width / 3, height: max(geo.size.height * 0.1, 120))
                    .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
                    .clipped()

                    Group {
                        VStack(alignment: .leading) {
                            Text(viewStore.name)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .lineLimit(2)
                                .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
                                .font(.system(size: 23, weight: .light, design: .rounded))
                                .padding([.top, .bottom], 6)

                            Text(viewStore.addressName)
                                .lineLimit(2)
                                .alignmentGuide(.leading) { viewDimensions in viewDimensions[.leading] }
                                .font(.system(size: 15, weight: .light, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.bottom, 5)

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
                    }
                    .padding(.leading, 8)

                    Spacer()

                }
                .frame(height: max(geo.size.height * 0.1, 120))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(
                            colorScheme == .dark
                            ? Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                            : Color(
                                #colorLiteral(
                                    red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)))
                )
                .padding([.leading, .trailing], 16)
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

struct EventRowView_Previews: PreviewProvider {

    static let store = Store(
        initialState: EventResponse.walkAroundDraff) {
            EventRowReducer()
        }

    static let location = Location(
        altitude: 0,
        coordinate: CLLocationCoordinate2D(latitude: 60.020532228306031, longitude: 30.388014239849944),
        course: 0,
        horizontalAccuracy: 0,
        speed: 0,
        timestamp: Date(timeIntervalSince1970: 0),
        verticalAccuracy: 0
      )

    static var previews: some View {
        GeometryReader { proxy in
            EventRowView(
                store: store,
                currentLocation: location,
                geo: proxy
            )
        }
    }
}
