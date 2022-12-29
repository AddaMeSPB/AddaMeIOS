//
//  LocationSearchReducer.swift
//  LocationSearchReducer
//
//  Created by Saroar Khandoker on 09.08.2021.
//

import Combine
import ComposableArchitecture
import Contacts
import MapKit
import SwiftUI
import CoreLocation
import MapKit
import ComposableCoreLocation
import AddaSharedModels

private struct LocationManagerId: Hashable {}

public struct LocationSearch: ReducerProtocol {

    public struct Error: Swift.Error, Equatable, Hashable {
      public let error: NSError?

      public init(_ error: Swift.Error?) {
        self.error = error as NSError?
      }
    }

    public struct State: Equatable, Identifiable {
      public init(
        id: UUID = UUID(),
        alert: AlertState<LocationSearch.Action>? = nil,
        searchTextInput: String = "",
        textFieldHeight: CGFloat = 50,
        isEditing: Bool = false,
        pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = [],
        isDidSelectedAddress: Bool = false,
        placeMark: Placemark,
        center: CLLocationCoordinate2D? = nil,
        radius: CLLocationDistance = 350_000,
        region: CoordinateRegion? = nil
      ) {
        self.id = id
        self.alert = alert
        self.searchTextInput = searchTextInput
        self.textFieldHeight = textFieldHeight
        self.isEditing = isEditing
        self.pointsOfInterest = pointsOfInterest
        self.isDidSelectedAddress = isDidSelectedAddress
        self.placeMark = placeMark
        self.center = center
        self.radius = radius
        self.region = region
      }

      public let id: UUID
      public var alert: AlertState<LocationSearch.Action>?
      public var searchTextInput: String = ""
      public var textFieldHeight: CGFloat = 50
      public var isEditing: Bool = false
      public var pointsOfInterest: IdentifiedArrayOf<MKLocalSearchCompletion> = []
      public var isDidSelectedAddress: Bool = false
      public var placeMark: Placemark
      public var center: CLLocationCoordinate2D?
      public var radius: CLLocationDistance = 350_000
      public var region: CoordinateRegion?
    }

    public enum Action: Equatable, Hashable {
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
      case eventCoordinate(Result<CLPlacemark, Error>)
      case region(CoordinateRegion)
      case backToformView
    }

    public var localSearch: LocalSearchManager
    @Dependency(\.mainQueue) var mainQueue

    public init(localSearch: LocalSearchManager) {
        self.localSearch = localSearch
    }

    func getCoordinate(_ addressString: String) -> Effect<CLPlacemark, Error> {
      return Effect<CLPlacemark, Error>.future { callback in
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
          if error != nil {
              print(#line, error as Any)
              callback(.failure(Error("cant find placemark from this address \(error!.localizedDescription)")))
          }

          if let placemark = placemarks?[0] {
            callback(.success(placemark))
          }
        }
      }
    }

    public var body: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {
            case .onAppear:

                state.region = CoordinateRegion(
                    center: state.placeMark.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.1,
                        longitudeDelta: 0.1
                    )
                )

                return localSearch.create(LocationManagerId(), [.address], state.placeMark.coordinate, 350_000)
                    .map(LocationSearch.Action.locationSearchManager)

            case .onDisappear:
                return .none
//                localSearch.destroy(id: LocationManagerId())
//                    .fireAndForget()

            case .alertDismissed:
                state.alert = nil
                return .none
            case let .searchTextInputChanged(string):

                state.searchTextInput = string
                return localSearch
                    .query(id: LocationManagerId(), fragment: string)
                    .receive(on: DispatchQueue.main)
                    .debounce(for: .milliseconds(150), scheduler: RunLoop.main, options: nil)
                    .fireAndForget()

            case let .textFieldHeightChanged(height):
                let minHeight: CGFloat = 50
                let maxHeight: CGFloat = 100

                if height < minHeight {
                    state.textFieldHeight = minHeight
                    return .none
                }

                if height > maxHeight {
                    state.textFieldHeight = maxHeight
                    return .none
                }

                state.textFieldHeight = height

                return .none
            case let .isEditing(trigger):
                if trigger == false {
                    state.searchTextInput = ""
                }
                state.isEditing = trigger
                return .none

            case let .locationSearchManager(.completerDidUpdateResults(completer: completer)):
                state.pointsOfInterest = .init(uniqueElements: completer.results)
                return .none

            case .locationSearchManager:
                return .none

            case let .cleanSearchText(isClean):
                if isClean { state.searchTextInput = "" }
                return .none

            case .eventCoordinate(.success(let place)):
                if let location = place.location {
                    state.center = location.coordinate
                    state.placeMark.coordinate = location.coordinate
                }

                state.region = CoordinateRegion(
                    center: state.placeMark.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.1,
                        longitudeDelta: 0.1
                    )
                )

                // close keyboard
                let resign = #selector(UIResponder.resignFirstResponder)
                UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                state.isDidSelectedAddress = true

                return .none

            case .eventCoordinate(.failure):
                state.alert = .init(title: TextState("Invalid address please choice valid address!"))
                return .none

            case let .didSelect(address: result):
                let address = result.title  // + " " + results.subtitle
                state.searchTextInput = result.title
                state.pointsOfInterest = []
                state.placeMark.title = result.title

                return getCoordinate(address)
                        .receive(on: mainQueue)
                        .catchToEffect()
                        .map(LocationSearch.Action.eventCoordinate)

            case .backToformView:
                return localSearch.destroy(id: LocationManagerId())
                    .fireAndForget()

            case .pointOfInterest(index: _, address: _):
                return .none
            case .region(_):
                return .none
            }
        }
    }
}

extension MKPlacemark {
  var formattedAddress: String? {
    guard let postalAddress = postalAddress else { return nil }
    return CNPostalAddressFormatter.string(
      from: postalAddress, style: .mailingAddress
    )
    .replacingOccurrences(of: "\n", with: " ")
  }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
