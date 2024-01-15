//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Saroar Khandoker on 28.07.2021.
//

import Combine
import ComposableArchitecture
import IdentifiedCollections
import MapKit
import Network
import SwiftUI
import SwiftUIExtension
import SwiftUIHelpers
import AddaSharedModels

extension LocationSearchView {
    public struct ViewState: Equatable, Hashable {
        public init(state: LocationSearch.State) {
            self.id = state.id
            self.alert = state.alert
            self.searchTextInput = state.searchTextInput
            self.textFieldHeight = state.textFieldHeight
            self.isEditing = state.isEditing
            self.pointsOfInterest = state.pointsOfInterest
            self.isDidSelectedAddress = state.isDidSelectedAddress
            self.center = state.center
            self.radius = state.radius
            self.region = state.region
            self.placeMark = state.placeMark
        }

    public let id: UUID
    public var alert: AlertState<LocationSearch.Action>?
    public var searchTextInput: String = ""
    public var textFieldHeight: CGFloat = 50
    public var isEditing: Bool = false
    public var pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = []
    public var isDidSelectedAddress: Bool = false
    public var center: CLLocationCoordinate2D?
    public var radius: CLLocationDistance?
    public var region: CoordinateRegion?
    public var placeMark: Placemark
  }

  public enum ViewAction {
    case onAppear
    case onDisappear
    case alertDismissed
    case searchTextInputChanged(String)
    case textFieldHeightChanged(CGFloat)
    case isEditing(Bool)
    case locationSearchManager(LocalSearchManager.Action)
    case cleanSearchText(Bool)
    case didSelect(address: MKLocalSearchCompletion)
    case pointOfInterest(index: LocationSearch.State.ID, address: MKLocalSearchCompletion)
    case region(CoordinateRegion)
    case backToformView
  }
}

public struct LocationSearchView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentationMode

  public init(store: StoreOf<LocationSearch>) {
    self.store = store
  }

  let store: StoreOf<LocationSearch>

    @State var tracking: MapUserTrackingMode = .follow

  public var body: some View {

      WithViewStore(self.store, observe: ViewState.init, send: LocationSearch.Action.view) { viewStore in
      ZStack(alignment: .bottomTrailing) {
        if viewStore.state.isDidSelectedAddress {
          ProgressView()
        }

        MapView(
            pointsOfInterest: [
                .init(
                    coordinate: viewStore.placeMark.coordinate,
                    subtitle: viewStore.placeMark.title,
                    title: viewStore.placeMark.subtitle
                )
            ],
            region: .constant(viewStore.region)
        )
        .ignoresSafeArea()

        VStack {
          HStack {
            DynamicHeightTextField(
              text: viewStore.binding(
                get: \.searchTextInput,
                send: ViewAction.searchTextInputChanged
              )
              .removeDuplicates(),

              height: viewStore.binding(
                get: \.textFieldHeight,
                send: ViewAction.textFieldHeightChanged
              )
            )
            .overlay(
              HStack {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.gray)
                  .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                  .padding(.bottom, 6)
                  .padding(.leading, -6)
                  .opacity(!viewStore.state.isEditing ? 1 : 0)

                if viewStore.state.isEditing {
                  Button {
                    viewStore.send(.cleanSearchText(true))
                  } label: {
                    Image(systemName: "multiply.circle.fill")
                      .foregroundColor(.gray)
                      .padding(.trailing, 0)
                      .padding(.bottom, 10)
                  }
                }
              }
            )
            .padding(EdgeInsets(top: 9, leading: 20, bottom: 0, trailing: 20))
            .onTapGesture {
              viewStore.send(.isEditing(true))
            }
          }
          .background(Color(.systemGray6))
          .clipShape(
            RoundedRectangle(
              cornerRadius: 25, style: .continuous
            )
          )
          .frame(
            maxWidth: .infinity,
            maxHeight: viewStore.state.textFieldHeight
          )

          Spacer()

          if !viewStore.state.pointsOfInterest.isEmpty {
            List(viewStore.state.pointsOfInterest) { localSearchCompletion in
              Button {
                viewStore.send(.didSelect(address: localSearchCompletion))
              } label: {
                VStack(alignment: .leading) {
                  Text(localSearchCompletion.title)
                  Text(localSearchCompletion.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
              }
            }
          }
        }
        .disabled(viewStore.state.isDidSelectedAddress)
        .onAppear { viewStore.send(.onAppear) }
        .padding(.horizontal)
        .padding(.top, 10)
//        .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)

          if viewStore.isDidSelectedAddress {
              Button {
                  viewStore.send(.backToformView)
              } label: {
                  Text("< Back")
                      .font(.system(size: 26, weight: .bold, design: .rounded))
                      .foregroundColor(.white)
                      .padding(.horizontal, 10)
              }
              .padding()
              .background(Color.blue )
              .clipShape(AnyShape(Capsule()))
              .padding()
          }
      }
    }
  }
}

//struct LocationSearchView_Previews: PreviewProvider {
//  static let store = Store(
//    initialState: LocationSearch.State.locationSearchPlacholder,
//    reducer: LocationSearch(localSearch: .live)
//  )
//
//  static var previews: some View {
////    Text("Click Play buttom for show search sheet").sheet(isPresented: .constant(true)) {
//        NavigationView {
//            LocationSearchView(store: store)
//                .environment(\.colorScheme, .dark)
//                .navigationTitle("Map")
//                .navigationBarTitleDisplayMode(.inline)
//        }
////    }
//  }
//}
