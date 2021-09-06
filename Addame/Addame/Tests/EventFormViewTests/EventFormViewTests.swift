//
//  EventFormViewTests.swift
//  EventFormViewTests
//
//  Created by Saroar Khandoker on 01.09.2021.
//

import ComposableArchitecture
import Contacts
import CoreLocation
import HttpRequest
import Intents
import KeychainService
import MapKit
import SharedModels
import XCTest

@testable import EventFormView

class EventFormViewTests: XCTestCase {
  let scheduler = DispatchQueue.test

  // swiftlint:disable function_body_length line_length
  func testCreatEvent() {
    let now = Date()
    let attachments = [
      Attachment(
        id: "5fb6736c1432f950f8ea2d33",
        type: .image,
        userId: "5fabb05d2470c17919b3c0e2",
        imageUrlString:
          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg",
        createdAt: now,
        updatedAt: now
      ),
      Attachment(
        id: "5fb6736c1432f950f8ea2d36",
        type: .image,
        userId: "5fabb05d2470c17919b3c0e2",
        imageUrlString:
          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg",
        createdAt: now,
        updatedAt: now
      ),
      Attachment(
        id: "5fb6bc48d63734254b0eb777",
        type: .image,
        userId: "5fabb05d2470c17919b3c0e2",
        imageUrlString:
          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811270871.jpeg",
        createdAt: now,
        updatedAt: now
      ),
    ]

    let cuser = User(
      id: "5fabb05d2470c17919b3c0e2",
      phoneNumber: "+79218821217",
      attachments: attachments,
      createdAt: now,
      updatedAt: now
    )

    let postAddress = CNMutablePostalAddress()
    postAddress.street = "улица Вавиловых, 8 к1,"
    postAddress.city = "Saint Petersburg"
    postAddress.subAdministrativeArea = "Saint Petersburg"
    postAddress.state = "Leningrad Oblast"
    postAddress.postalCode = "195257"
    postAddress.country = "Russia"
    postAddress.isoCountryCode = "ru"

    let placeMark = MKPlacemark(
      location: CLLocation(latitude: +60.02020100, longitude: +30.38803500),
      name: "улица Вавиловых, 8 к1",
      postalAddress: postAddress
    )

    let location = placeMark.location?.coordinate
    let eventAddress = "\(placeMark.postalAddress)"

    let state = EventFormState(
      placeMark: placeMark,
      eventAddress: eventAddress,
      eventCoordinate: location,
      currentUser: cuser
    )

    let environment = EventFormEnvironment(
      eventClient: .happyPath,
      mainQueue: scheduler.eraseToAnyScheduler()
    )

    let store = TestStore(
      initialState: state,
      reducer: eventFormReducer,
      environment: environment
    )

    store.send(.titleChanged("Walk Around")) {
      $0.title = "Walk Around"
    }

    store.send(.selectedDurations(.FourHours)) {
      let duration = DurationButtons.self
      $0.durationRawValue = duration.FourHours.rawValue
      $0.selectedDutaionButtons = duration.FourHours
      $0.durationIntValue = duration.FourHours.value
    }

    store.send(.liveLocationToggleChanged(true)) {
      $0.liveLocationToggleisOn.toggle()
    }

    store.send(.isSearchSheet(isPresented: false)) {
      $0.locationSearchState = nil
    }

    store.send(.selectedDurationIndex(2)) {
      $0.selectedCateforyIndex = 2
    }

    store.send(.submitButtonTapped) {
      $0.isPostRequestOnFly = true
    }
    scheduler.advance()
    store.receive(
      .eventsResponse(
        .success(
          .init(
            id: "5fb1510012de9980bd0c2efc",
            name: "Testing data",
            details: "Waitting for details",
            imageUrl:
              "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
            duration: 14400, categories: "General",
            isActive: true, addressName: "8к1литД улица Вавиловых , Saint Petersburg",
            type: .Point, sponsored: false, overlay: false,
            coordinates: [60.020532228306031, 30.388014239849944]
          )
        )
      )
    )
    scheduler.advance(by: 4)
    store.receive(.backToPVAfterCreatedEventSuccessfully)
  }
}
