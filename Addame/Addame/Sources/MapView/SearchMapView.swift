//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Saroar Khandoker on 28.07.2021.
//

import ComposableArchitecture
import Combine
import SwiftUI
import SwiftUIExtension
import Network
import MapKit
import IdentifiedCollections

extension LocationSearchView {
  public struct ViewState: Equatable, Hashable {

    public let id: UUID
    public var searchTextInput: String = ""
    public var textFieldHeight: CGFloat = 50
    public var isEditing: Bool = false
    public var pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = []
    public var isDidSelectedAddress: Bool = false
  }

  public enum ViewAction {
    case onAppear
    case onDisappear
    case searchTextInputChanged(String)
    case textFieldHeightChanged(CGFloat)
    case isEditing(Bool)
    case locationSearchManager(LocalSearchManager.Action)
    case cleanSearchText(Bool)
    case didSelect(address: MKLocalSearchCompletion)
    case pointOfInterest(index: LocationSearchState.ID, address: MKLocalSearchCompletion)
  }
}

public struct LocationSearchView: View {

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentationMode

  public init(store: Store<LocationSearchState, LocationSearchAction>) {
    self.store = store
  }

  let store: Store<LocationSearchState, LocationSearchAction>

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: LocationSearchAction.view
      )
    ) { viewStore in
      ZStack(alignment: .center) {
        if viewStore.state.isDidSelectedAddress {
          ProgressView()
        }

        VStack {
          HStack {
            DynamicHeightTextField(
              text: viewStore.binding(
                get: \.searchTextInput,
                send: ViewAction.searchTextInputChanged
              ),

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
                    .opacity(!viewStore.state.isEditing ? 1 : 0 )

                  if viewStore.state.isEditing {
                    Button(action: {
                      viewStore.send(.cleanSearchText(true))
                    }) {
                      Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    }
                  }
                }
              )
              .padding(EdgeInsets(top: 9, leading: 20, bottom: 0, trailing: 20) )
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
              Button(action: {
                viewStore.send(.didSelect(address: localSearchCompletion) )
              }) {
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
        .onDisappear { viewStore.send(.onDisappear) }
        .padding(.horizontal)
        .padding(.top, 30)
      }
    }
  }
}

struct LocationSearchView_Previews: PreviewProvider {

  static let store = Store(
    initialState: LocationSearchState.locationSearchPlacholder,
    reducer: locationSearchReducer,
    environment: LocationEnvironment(
      localSearch: .live,
      mainQueue: .immediate
    )
  )

  static var previews: some View {
    Text("Click Play buttom for show search sheet").sheet(isPresented: .constant(true)) {
      LocationSearchView(store: store)
        .environment(\.colorScheme, .dark)
    }
  }
}
