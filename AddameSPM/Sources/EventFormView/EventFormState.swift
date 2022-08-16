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
import AddaSharedModels
import BSON

extension EventFormState {
  public static let validEventForm = Self(
    title: "Walk around",
    durationRawValue: "7200",
    eventAddress: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия", isPostRequestOnFly: false,
    isEventCreatedSuccessfully: false
  )

  public static let inValidEventForm = Self(
    title: "Walk around Walk around Walk around Walk around Walk around",
    durationRawValue: "4hr",
    isPostRequestOnFly: false,
    isEventCreatedSuccessfully: false
  )
}

extension CategoryResponse: Identifiable {}

public struct EventFormState: Equatable {

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

  public var actionSheet: ConfirmationDialogState<EventFormAction>?
  public var alert: AlertState<EventFormAction>?
  public var locationSearchState: LocationSearchState?

  public var isPostRequestOnFly: Bool = false
  public var isEventCreatedSuccessfully: Bool = false
  public var currentUser: UserOutput = .withFirstName

    public init(
      title: String = "", textFieldHeight: CGFloat = 0,
      durationRawValue: String = DurationButtons.Four_Hours.rawValue,
      durationIntValue: Int = 0,
      selectedCateforyID: ObjectId? = nil,
      selectedDurationIndex: Int = 0,
      showCategorySheet: Bool = false, liveLocationToggleisOn: Bool = true,
      moveMapView: Bool = false, selectLocationtoggleisOn: Bool = false,
      selectedTag: String? = nil, showSuccessActionSheet: Bool = false,
      placeMark: CLPlacemark? = nil,
      selectedPlace: EventResponse? = nil, currentPlace: EventResponse? = nil,
      eventAddress: String = "",
      eventCoordinate: CLLocationCoordinate2D? = nil,
      selectedDutaionButtons: DurationButtons = .Four_Hours,
      durations: [String] = DurationButtons.allCases.map { $0.rawValue },
      categories: IdentifiedArrayOf<CategoryResponse> = [],
      actionSheet: ConfirmationDialogState<EventFormAction>? = nil,
      alert: AlertState<EventFormAction>? = nil,
      locationSearchState _: LocationSearchState? = nil,
      isPostRequestOnFly: Bool = false,
      isEventCreatedSuccessfully: Bool = false,
      currentUser: UserOutput = .withFirstName
    ) {
      self.title = title
      self.textFieldHeight = textFieldHeight
      self.durationRawValue = durationRawValue
      self.durationIntValue = durationIntValue
      self.selectedCateforyID = selectedCateforyID
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
      self.categories = categories
      self.actionSheet = actionSheet
      self.alert = alert
      self.isPostRequestOnFly = isPostRequestOnFly
      self.isEventCreatedSuccessfully = isEventCreatedSuccessfully
      self.currentUser = currentUser
    }
}

extension EventFormState {
  var view: EventFormView.ViewState {
    EventFormView.ViewState(
      title: title,
      textFieldHeight: textFieldHeight,
      durationRawValue: durationRawValue,
      selectedDurationIndex: selectedDurationIndex,
      selectedCateforyID: selectedCateforyID,
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
      actionSheet: actionSheet,
      alert: alert,
      locationSearchState: locationSearchState,
      isPostRequestOnFly: isPostRequestOnFly,
      isEventCreatedSuccessfully: isEventCreatedSuccessfully,
      category: category,
      currentUser: currentUser
    )
  }
}
