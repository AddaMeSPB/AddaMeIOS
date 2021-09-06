//
//  EventFormState.swift
//  EventFormState
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import ComposableArchitecture
import ComposableArchitectureHelpers
import Foundation
import MapKit
import MapView
import SharedModels

extension EventFormState {
  public static let eventFormPlacholder = Self(
    title: "Walk around",
    isPostRequestOnFly: true,
    isEventCreatedSuccessfully: true
  )
}

public struct EventFormState: Equatable {
  public init(
    title: String = String.empty, textFieldHeight: CGFloat = 0,
    durationRawValue: String = DurationButtons.FourHours.rawValue,
    durationIntValue: Int = 0,
    categoryRawValue: String = Categories.General.rawValue,
    selectedCateforyIndex: Int = 0, selectedDurationIndex: Int = 0,
    showCategorySheet: Bool = false, liveLocationToggleisOn: Bool = true,
    moveMapView: Bool = false, selectLocationtoggleisOn: Bool = false,
    selectedTag: String? = nil, showSuccessActionSheet: Bool = false,
    placeMark: CLPlacemark? = nil,
    selectedPlace: EventResponse.Item? = nil, currentPlace: EventResponse.Item? = nil,
    eventAddress: String = "",
    eventCoordinate: CLLocationCoordinate2D? = nil,
    selectedDutaionButtons: DurationButtons = .FourHours,
    durations: [String] = DurationButtons.allCases.map { $0.rawValue },
    catagories: [String] = Categories.allCases.map { $0.rawValue },
    actionSheet: ActionSheetState<EventFormAction>? = nil,
    alert: AlertState<EventFormAction>? = nil,
    locationSearchState _: LocationSearchState? = nil,
    isPostRequestOnFly: Bool = false,
    isEventCreatedSuccessfully: Bool = false,
    currentUser: User = .draff
  ) {
    self.title = title
    self.textFieldHeight = textFieldHeight
    self.durationRawValue = durationRawValue
    self.durationIntValue = durationIntValue
    self.categoryRawValue = categoryRawValue
    self.selectedCateforyIndex = selectedCateforyIndex
    self.selectedDurationIndex = selectedDurationIndex
    self.showCategorySheet = showCategorySheet
    self.liveLocationToggleisOn = liveLocationToggleisOn
    self.moveMapView = moveMapView
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
    self.catagories = catagories
    self.actionSheet = actionSheet
    self.alert = alert
    self.isPostRequestOnFly = isPostRequestOnFly
    self.isEventCreatedSuccessfully = isEventCreatedSuccessfully
    self.currentUser = currentUser
  }

  public var title = String.empty
  public var textFieldHeight: CGFloat = 30
  public var durationRawValue: String = DurationButtons.FourHours.rawValue
  public var durationIntValue: Int = 0
  public var categoryRawValue: String = Categories.General.rawValue
  public var selectedCateforyIndex: Int = 0
  public var selectedDurationIndex: Int = 0
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

  public var selectedPlace: EventResponse.Item?
  public var currentPlace: EventResponse.Item?
  public var eventAddress: String = ""
  public var eventCoordinate: CLLocationCoordinate2D?

  public var selectedDutaionButtons: DurationButtons = .FourHours
  public var durations = DurationButtons.allCases.map { $0.rawValue }
  public var catagories = Categories.allCases.map { $0.rawValue }

  public var actionSheet: ActionSheetState<EventFormAction>?
  public var alert: AlertState<EventFormAction>?
  public var locationSearchState: LocationSearchState?

  public var isPostRequestOnFly: Bool = false
  public var isEventCreatedSuccessfully: Bool = false
  public var currentUser: User = .draff
}

extension EventFormState {
  var view: EventFormView.ViewState {
    EventFormView.ViewState(
      title: title,
      textFieldHeight: textFieldHeight,
      durationRawValue: durationRawValue,
      categoryRawValue: categoryRawValue,
      selectedCateforyIndex: selectedCateforyIndex,
      selectedDurationIndex: selectedDurationIndex,
      showCategorySheet: showCategorySheet,
      liveLocationToggleisOn: liveLocationToggleisOn,
      moveMapView: moveMapView,
      selectLocationtoggleisOn: selectLocationtoggleisOn,
      selectedTag: selectedTag,
      showSuccessActionSheet: showSuccessActionSheet,
      placeMark: placeMark,
      selectedPlace: selectedPlace,
      currentPlace: currentPlace,
      eventAddress: eventAddress,
      selectedDutaionButtons: selectedDutaionButtons,
      durations: durations,
      catagories: catagories,
      actionSheet: actionSheet,
      alert: alert,
      locationSearchState: locationSearchState,
      isPostRequestOnFly: isPostRequestOnFly,
      isEventCreatedSuccessfully: isEventCreatedSuccessfully,
      currentUser: currentUser
    )
  }
}
