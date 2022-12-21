//
//  EventFormReducer.swift
//  EventFormReducer
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import ComposableArchitecture
import ComposablePresentation
import Foundation
import MapView
import AddaSharedModels
import SwiftUI
import BSON
import MapKit
import APIClient

public struct HangoutForm: ReducerProtocol {
    public struct State: Equatable {
        public var title = ""
        public var textFieldHeight: CGFloat = 30
        public var durationRawValue: String = DurationButtons.Four_Hours.rawValue
        public var durationIntValue: Int = 0
        public var selectedDurationIndex: Int = 0

        public var selectedCateforyID: ObjectId?
        public var showCategorySheet = false

        public var liveLocationToggleisOn = true
        public var moveMapView = false
        public var selectLocationtoggleisOn = false {
          willSet {
            liveLocationToggleisOn = false
          }
        }

        public var selectedTag: String?
        public var showSuccessActionSheet = false
        public var placeMark: CLPlacemark?

        public var selectedPlace: EventResponse?
        public var currentPlace: EventResponse?
        public var eventAddress: String = ""
        public var eventCoordinate: CLLocationCoordinate2D?

        public var selectedDutaionButtons: DurationButtons = .Four_Hours
        public var durations = DurationButtons.allCases.map { $0.rawValue }
        public var categories: IdentifiedArrayOf<CategoryResponse> = [] // [CategoryResponse] = []
        public var category: String = ""

        public var actionSheet: ConfirmationDialogState<Action>?
        public var alert: AlertState<Action>?
        public var locationSearchState: LocationSearchState?

        public var isPostRequestOnFly: Bool = false
        public var isEventCreatedSuccessfully: Bool = false
        public var currentUser: UserOutput = .withFirstName
    }

    public enum Action: Equatable {
        case didAppear
        case didDisappear
        case titleChanged(String)
        case textFieldHeightChanged(CGFloat)
        case selectedDurations(DurationButtons)
        case selectedCategory(AddaSharedModels.CategoryResponse)
        case selectedDurationIndex(Int)
        case showCategorySheet(Bool)
        case liveLocationToggleChanged(Bool)
        case isSearchSheet(isPresented: Bool)
        case locationSearch(LocationSearchAction)
        case eventResponse(TaskResult<EventResponse>)
        case categoryResponse(TaskResult<CategoriesResponse>)
        case backToPVAfterCreatedEventSuccessfully

        case submitButtonTapped
        case actionSheetButtonTapped
        case actionSheetCancelTapped
        case actionSheetDismissed
        case alertButtonTapped
        case alertCancelTapped
        case alertDismissed
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.mainQueue) var mainQueue

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didAppear:
      //    guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
      //      // assertionFailure("current user is missing")
      //      return .none
      //    }
      //    state.currentUser = currentUSER

            return  .task {
                .categoryResponse(
                  await TaskResult {
                      try await apiClient.request(
                          for: .eventEngine(.categories(.list)),
                          as: CategoriesResponse.self,
                          decoder: .iso8601
                      )
                  }
                )
            }

        case .didDisappear:
          return .none
        case let .titleChanged(string):
          state.title = string
          return .none
        case let .selectedDurations(duration):
          // duration.value -> 3600
          state.durationRawValue = duration.rawValue
          state.selectedDutaionButtons = duration
          state.durationIntValue = duration.value
          return .none
        case let .showCategorySheet(isPresent):
          return .none
        case let .liveLocationToggleChanged(liveLocationEnabled):
          state.liveLocationToggleisOn.toggle()
          return .none

        case let .isSearchSheet(isPresented: isPresented):
          state.locationSearchState = isPresented ? LocationSearchState() : nil
          return .none

        case let .selectedDurationIndex(int):
          state.selectedDurationIndex = int
          return .none

        case .backToPVAfterCreatedEventSuccessfully:
          return .none

        case let .eventResponse(.success(event)):
          state.isEventCreatedSuccessfully = true
          state.isPostRequestOnFly = false
          return Effect(value: Action.backToPVAfterCreatedEventSuccessfully)
                .delay(for: 1.6, scheduler: mainQueue)
            .eraseToEffect()

        case let .eventResponse(.failure(error)):
          state.isPostRequestOnFly = false
          return .none

        case let  .categoryResponse(.success(categoriesResponse)):
            state.categories = .init(uniqueElements: categoriesResponse.categories)
            return .none

        case let  .categoryResponse(.failure(error)):
            return .none

        case .submitButtonTapped:

          guard let coordinate = state.eventCoordinate else {
            // alert action for valid form notification
            state.alert = .init(title: TextState("Invalid address please valid address please"))
            return .none
          }

            guard let categoriesId = state.selectedCateforyID else {
                state.alert = .init(title: TextState("Please seletect category!"))
                return .none
            }

          state.isPostRequestOnFly = true
            let eventInput = EventInput(
              name: state.title,
              details: "",
              imageUrl: state.currentUser.attachments?.last?.imageUrlString,
              duration: state.durationIntValue,
              isActive: true,
              ownerId: ObjectId(),
              categoriesId: categoriesId,
              addressName: state.eventAddress,
              sponsored: false,
              overlay: false,
              type: .Point,
              coordinates: [coordinate.longitude, coordinate.latitude]
              // mongoDB coordinate have to long then lat
              // selectedPlace.coordinatesMongoDouble
            )


            return  .task {
                .eventResponse(
                  await TaskResult {
                      try await apiClient.request(
                        for: .eventEngine(.events(.create(eventInput: eventInput))),
                          as: EventResponse.self,
                          decoder: .iso8601
                      )
                  }
                )
            }

        case .actionSheetButtonTapped:

          // menu context please
          state.actionSheet = .init(
            title: .init("Categories"),
            message: .init("Select category."),
            buttons: [.cancel(.init("Cancel"))]
          )

            state.actionSheet?.buttons = state.categories
            .map { item in
              .default(
                .init("\(item.name)"),
                action: .send(.selectedCategory(item))
              )
            }

          return .none

        case .actionSheetCancelTapped:
          return .none

        case .actionSheetDismissed:
          state.actionSheet = nil
          return .none

        case .alertButtonTapped:
          return .none
        case .alertCancelTapped:
          state.alert = nil
          return .none

        case .alertDismissed:
          state.alert = nil
          return .none

        case let .selectedCategory(category):
            state.selectedCateforyID = category.id
            state.category = category.name
          return .none

        case let .textFieldHeightChanged(height):
          let minHeight: CGFloat = 30
          let maxHeight: CGFloat = 70

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

        case let .locationSearch(.didSelect(address: results)):
          state.eventAddress = results.title + " " + results.subtitle
          return .none

        case let .locationSearch(.eventCoordinate(.success(placemark))):
          if let location = placemark.location {
            state.locationSearchState = nil
            state.eventCoordinate = location.coordinate
          }

          return .none

        case let .locationSearch(action):
          return .none
        }
    }
}

//public let eventFormReducer = Reducer<
//  EventFormState, EventFormAction, EventFormEnvironment
//> { state, action, environment in
//
//  switch action {
//  case .didAppear:
////    guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
////      // assertionFailure("current user is missing")
////      return .none
////    }
////    state.currentUser = currentUSER
//
//      return .task {
//          do {
//              let categories = try await environment.eventClient.categoriesFetch()
//              return EventFormAction.categoryResponse(.success(categories))
//          } catch {
//              return EventFormAction.categoryResponse(.failure(.custom("cant fetch category from server", error)))
//          }
//      }
//  case .didDisappear:
//    return .none
//  case let .titleChanged(string):
//    state.title = string
//    return .none
//  case let .selectedDurations(duration):
//    // duration.value -> 3600
//    state.durationRawValue = duration.rawValue
//    state.selectedDutaionButtons = duration
//    state.durationIntValue = duration.value
//    return .none
//  case let .showCategorySheet(isPresent):
//    return .none
//  case let .liveLocationToggleChanged(liveLocationEnabled):
//    state.liveLocationToggleisOn.toggle()
//    return .none
//
//  case let .isSearchSheet(isPresented: isPresented):
//    state.locationSearchState = isPresented ? LocationSearchState() : nil
//    return .none
//
//  case let .selectedDurationIndex(int):
//    state.selectedDurationIndex = int
//    return .none
//
//  case .backToPVAfterCreatedEventSuccessfully:
//    return .none
//
//  case let .eventsResponse(.success(event)):
//    state.isEventCreatedSuccessfully = true
//    state.isPostRequestOnFly = false
//    return Effect(value: EventFormAction.backToPVAfterCreatedEventSuccessfully)
//          .delay(for: 1.6, scheduler: environment.mainQueue)
//      .eraseToEffect()
//
//  case let .eventsResponse(.failure(error)):
//    state.isPostRequestOnFly = false
//    return .none
//
//  case let  .categoryResponse(.success(categoriesResponse)):
//      state.categories = .init(uniqueElements: categoriesResponse.categories)
//      return .none
//
//  case let  .categoryResponse(.failure(error)):
//      return .none
//
//  case .submitButtonTapped:
//
//    guard let coordinate = state.eventCoordinate else {
//      // alert action for valid form notification
//      state.alert = .init(title: TextState("Invalid address please valid address please"))
//      return .none
//    }
//
//      guard let categoriesId = state.selectedCateforyID else {
//          state.alert = .init(title: TextState("Please seletect category!"))
//          return .none
//      }
//
//    state.isPostRequestOnFly = true
//      let eventInput = EventInput(
//        name: state.title,
//        details: "",
//        imageUrl: state.currentUser.attachments?.last?.imageUrlString,
//        duration: state.durationIntValue,
//        isActive: true,
//        ownerId: ObjectId(),
//        categoriesId: categoriesId,
//        addressName: state.eventAddress,
//        sponsored: false,
//        overlay: false,
//        type: .Point,
//        coordinates: [coordinate.longitude, coordinate.latitude]
//        // mongoDB coordinate have to long then lat
//        // selectedPlace.coordinatesMongoDouble
//      )
//
//      return .task {
//          do {
//              let eventCreatResponse = try await environment.eventClient.create(eventInput)
//              return EventFormAction.eventsResponse(.success(eventCreatResponse))
//          } catch {
//              return EventFormAction.eventsResponse(.failure(.custom("cant create event!", error)))
//          }
//      }
//
//  case .actionSheetButtonTapped:
//
//    // menu context please
//    state.actionSheet = .init(
//      title: .init("Categories"),
//      message: .init("Select category."),
//      buttons: [.cancel(.init("Cancel"))]
//    )
//
//      state.actionSheet?.buttons = state.categories
//      .map { item in
//        .default(
//          .init("\(item.name)"),
//          action: .send(.selectedCategory(item))
//        )
//      }
//
//    return .none
//
//  case .actionSheetCancelTapped:
//    return .none
//
//  case .actionSheetDismissed:
//    state.actionSheet = nil
//    return .none
//
//  case .alertButtonTapped:
//    return .none
//  case .alertCancelTapped:
//    state.alert = nil
//    return .none
//
//  case .alertDismissed:
//    state.alert = nil
//    return .none
//
//  case let .selectedCategory(category):
//      state.selectedCateforyID = category.id
//      state.category = category.name
//    return .none
//
//  case let .textFieldHeightChanged(height):
//    let minHeight: CGFloat = 30
//    let maxHeight: CGFloat = 70
//
//    if height < minHeight {
//      state.textFieldHeight = minHeight
//      return .none
//    }
//
//    if height > maxHeight {
//      state.textFieldHeight = maxHeight
//      return .none
//    }
//
//    state.textFieldHeight = height
//    return .none
//
//  case let .locationSearch(.didSelect(address: results)):
//    state.eventAddress = results.title + " " + results.subtitle
//    return .none
//
//  case let .locationSearch(.eventCoordinate(.success(placemark))):
//    if let location = placemark.location {
//      state.locationSearchState = nil
//      state.eventCoordinate = location.coordinate
//    }
//
//    return .none
//
//  case let .locationSearch(action):
//    return .none
//  }
//}
//.debug()
//.presenting(
//  locationSearchReducer,
//  state: .keyPath(\.locationSearchState),
//  id: .notNil(),
//  action: /EventFormAction.locationSearch,
//  environment: { _ in LocationEnvironment.live }
//)
