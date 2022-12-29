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

   private static var placeMarkDemo: Placemark {
        let location = CLLocationCoordinate2D(latitude: 60.02071653, longitude: 30.38745188)
        let mkPlacemark = MKPlacemark(coordinate: location)
        let mk = MKMapItem(placemark: mkPlacemark)
        let placemark = Placemark(rawValue: mk.placemark)
        return placemark
    }

  public static let validEventForm = Self(
    title: "",
    durationRawValue: "7200",
    placeMark: placeMarkDemo,
    eventAddress: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия",
    categories: .init(uniqueElements: [CategoryResponse.exploreAreaDraff]),
    isPostRequestOnFly: false,
    isEventCreatedSuccessfully: true,
    currentUser: .demo
  )

  public static let invalidEventForm = Self(
    title: "Walk around Walk around Walk around Walk around Walk around",
    durationRawValue: "4hr",
    placeMark: placeMarkDemo,
    eventAddress: "",
    isPostRequestOnFly: false,
    isEventCreatedSuccessfully: false,
    currentUser: .demo
  )
}

extension CategoryResponse: Identifiable {}
