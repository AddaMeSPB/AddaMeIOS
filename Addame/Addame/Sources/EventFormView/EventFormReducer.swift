//
//  EventFormReducer.swift
//  EventFormReducer
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import SharedModels
import HttpRequest
import MapView

public let eventFormReducer = Reducer<
  EventFormState, EventFormAction, EventFormEnvironment
> { state, action, environment in

  switch action {
  case .didAppear:
    return .none
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
    state.selectedCateforyIndex = int
    return .none

  case .backToPVAfterCreatedEventSuccessfully:
    return .none

  case .successFullMsg:
    state.isEventCreatedSuccessfully = true
    state.isPostRequestOnFly = false
    return Effect(value: EventFormAction.backToPVAfterCreatedEventSuccessfully)
      .delay(for: 3, scheduler: environment.mainQueue)
      .eraseToEffect()

  case let .eventsResponse(.success(event)):

    return Effect(value: EventFormAction.successFullMsg)
      .receive(on: environment.mainQueue)
      .eraseToEffect()

  case let .eventsResponse(.failure(error)):
    state.isPostRequestOnFly = false
    return .none

  case .submitButtonTapped:
    guard let coordinate = state.eventCoordinate else {
      // alert action for valid form notification
      state.alert = .init(title: TextState("Invalid address please valid address please"))
      return .none
    }

    let event = Event(
      name: state.title,
      details: "",
      imageUrl: environment.currentUser.attachments?.last?.imageUrlString,
      duration: state.durationIntValue,
      categories: state.categoryRawValue,
      isActive: true,
      addressName: state.eventAddress,
      type: .Point,
      sponsored: false,
      overlay: false,
      coordinates: [coordinate.longitude, coordinate.latitude] // selectedPlace.coordinatesMongoDouble
    )

    state.isPostRequestOnFly = true
    return environment.eventClient.create(event, "")
      .retry(3)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EventFormAction.eventsResponse)

  case .actionSheetButtonTapped:
    let cancel = ActionSheetState<EventFormAction>.Button.cancel()

    var alertButtons: [ActionSheetState<EventFormAction>.Button] = Categories.allCases.enumerated().map { _, item in
      return .default(
        .init("\(item.rawValue)"),
        send: .selectedCategories(item)
      )
    }
    alertButtons.append(cancel)

    state.actionSheet = .init(
      title: .init("Action sheet"),
      message: .init("This is an action sheet."),
      buttons: alertButtons
    )
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

  case let .selectedCategories(categories):
    state.categoryRawValue = categories.rawValue
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
.presents(
  locationSearchReducer,
  state: \.locationSearchState,
  action: /EventFormAction.locationSearch,
  environment: { _ in
    LocationEnvironment(localSearch: .live, mainQueue: .immediate)
  }
)
