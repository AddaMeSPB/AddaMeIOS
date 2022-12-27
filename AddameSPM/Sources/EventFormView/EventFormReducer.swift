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
        public var maxTitleCharacters: Int = 27
        public var textFieldHeight: CGFloat = 30
        public var durationRawValue: String = DurationButtons.Four_Hours.rawValue
        public var durationIntValue: Int = 0
        public var selectedDurationIndex: Int = 0

        public var selectedCateforyID: ObjectId?
        public var showCategorySheet = false

        public var liveLocationToggleisOn = true

        public var selectLocationtoggleisOn = false {
          willSet {
            liveLocationToggleisOn = false
          }
        }

        public var selectedTag: String?
        public var showSuccessActionSheet = false
        public var placeMark: Placemark

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
        public var locationSearchState: LocationSearch.State?

        public var isPostRequestOnFly: Bool = false
        public var isEventCreatedSuccessfully: Bool = false
        public var currentUser: UserGetObject = .demo
        public var isAllFeildsAreValid: Bool = false

        public init(
            title: String = "", textFieldHeight: CGFloat = 30,
            durationRawValue: String = DurationButtons.Four_Hours.rawValue,
            durationIntValue: Int = 0, selectedDurationIndex: Int = 0,
            selectedCateforyID: ObjectId? = nil, showCategorySheet: Bool = false,
            liveLocationToggleisOn: Bool = true,
            selectLocationtoggleisOn: Bool = false, selectedTag: String? = nil,
            showSuccessActionSheet: Bool = false,
            placeMark: Placemark,
            selectedPlace: EventResponse? = nil, currentPlace: EventResponse? = nil,
            eventAddress: String = "",
            eventCoordinate: CLLocationCoordinate2D? = nil,
            selectedDutaionButtons: DurationButtons = .Four_Hours,
            durations: [String] = DurationButtons.allCases.map { $0.rawValue },
            categories: IdentifiedArrayOf<CategoryResponse> = [], category: String = "",
            actionSheet: ConfirmationDialogState<HangoutForm.Action>? = nil,
            alert: AlertState<HangoutForm.Action>? = nil,
            locationSearchState: LocationSearch.State? = nil, isPostRequestOnFly: Bool = false,
            isEventCreatedSuccessfully: Bool = false,
            currentUser: UserGetObject = .demo
        ) {
            self.title = title
            self.textFieldHeight = textFieldHeight
            self.durationRawValue = durationRawValue
            self.durationIntValue = durationIntValue
            self.selectedDurationIndex = selectedDurationIndex
            self.selectedCateforyID = selectedCateforyID
            self.showCategorySheet = showCategorySheet
            self.liveLocationToggleisOn = liveLocationToggleisOn
            self.selectLocationtoggleisOn = selectLocationtoggleisOn
            self.selectedTag = selectedTag
            self.showSuccessActionSheet = showSuccessActionSheet
            self.placeMark = placeMark
            self.selectedPlace = selectedPlace
            self.currentPlace = currentPlace
            self.eventAddress = eventAddress
            self.eventCoordinate = eventCoordinate
            self.selectedDutaionButtons = selectedDutaionButtons
            self.durations = durations
            self.categories = categories
            self.category = category
            self.actionSheet = actionSheet
            self.alert = alert
            self.locationSearchState = locationSearchState
            self.isPostRequestOnFly = isPostRequestOnFly
            self.isEventCreatedSuccessfully = isEventCreatedSuccessfully
            self.currentUser = currentUser
        }
    }

    public enum Action: Equatable {
        case onAppear
        case onDisappear
        case titleChanged(String)
        case textFieldHeightChanged(CGFloat)
        case selectedDurations(DurationButtons)
        case selectedCategory(AddaSharedModels.CategoryResponse)
        case selectedDurationIndex(Int)
        case showCategorySheet(Bool)
        case liveLocationToggleChanged(Bool)
        case isLocationSearch(navigate: Bool)
        case locationSearch(LocationSearch.Action)
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
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            var now = 0
            var then = 0

            switch action {

            case .onAppear:

                state.eventAddress = state.placeMark.title ?? ""
                state.eventCoordinate = state.placeMark.coordinate
                var currentUser: UserGetObject = .demo

                do {
                    currentUser = try self.keychainClient.readCodable(.user, self.build.identifier(), UserGetObject.self)
                } catch {
                    print("something....")
                }

                state.currentUser = currentUser
                
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

            case .onDisappear:
                return .none

            case let .titleChanged(newText):

                now = newText.count
                then = state.title.count

                if now > then {
                    state.maxTitleCharacters -= 1
                } else if now < then {
                    state.maxTitleCharacters += 1
                }
                
                state.title = newText

                return .none

            case let .selectedDurations(duration):
                // duration.value -> 3600
                state.durationRawValue = duration.rawValue
                state.selectedDutaionButtons = duration
                state.durationIntValue = duration.value
                return .none

            case .showCategorySheet:
                return .none

            case .liveLocationToggleChanged:
                state.liveLocationToggleisOn.toggle()
                return .none

            case let .isLocationSearch(navigate: active):
                state.locationSearchState = active ? LocationSearch.State(placeMark: state.placeMark) : nil
                return .none

            case let .selectedDurationIndex(int):
                state.selectedDurationIndex = int
                return .none

            case .backToPVAfterCreatedEventSuccessfully:
                return .none

            case .eventResponse(.success):
                state.isEventCreatedSuccessfully = true
                state.isPostRequestOnFly = false
                return Effect(value: Action.backToPVAfterCreatedEventSuccessfully)
                    .delay(for: 1.0, scheduler: mainQueue)
                    .eraseToEffect()

            case .eventResponse(.failure(_)):
                state.isPostRequestOnFly = false
                return .none

            case let  .categoryResponse(.success(categoriesResponse)):
                state.categories = .init(uniqueElements: categoriesResponse.categories)
                return .none

            case .categoryResponse(.failure(_)):
                return .none

            case .submitButtonTapped:

                guard let coordinate = state.eventCoordinate else {
                    // alert action for valid form notification
                    state.alert = .init(
                        title: TextState("Invalid address please choice valid address!")
                    )
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

            case let .locationSearch(.didSelect(address: result)):
                state.eventAddress = result.title + " " + result.subtitle
                return .none

            case let .locationSearch(.eventCoordinate(.success(clPlacemark))):

                if let coordinate = clPlacemark.location?.coordinate {
                    let mkPlacemark = MKPlacemark(coordinate: coordinate)
                    var placemark = Placemark(rawValue: mkPlacemark)
                    placemark.title = clPlacemark.makeAddressString()
                    state.placeMark = placemark
                    state.eventCoordinate = coordinate
                }

                return .none

            case .locationSearch(.backToformView):
                return .run { send in
                    await send(.isLocationSearch(navigate: false))
                }

            case .locationSearch:
                return .none
            }
        }
        .ifLet(\.locationSearchState, action: /HangoutForm.Action.locationSearch) {
            LocationSearch(localSearch: .live)
        }
    }
}

extension CLPlacemark {

    func makeAddressString() -> String {
        return [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
            .compactMap({ $0 })
            .joined(separator: " ")
    }

    var customAddress: String {
            get {
                return [[thoroughfare, subThoroughfare], [postalCode, locality]]
                    .map { (subComponents) -> String in
                        // Combine subcomponents with spaces (e.g. 1030 + City),
                        subComponents.compactMap({ $0 }).joined(separator: " ")
                    }
                    .filter({ return !$0.isEmpty }) // e.g. no street available
                    .joined(separator: ", ") // e.g. "MyStreet 1" + ", " + "1030 City"
            }
        }
}
