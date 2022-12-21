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

extension HangoutForm.State {
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


extension HangoutForm.State {
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
