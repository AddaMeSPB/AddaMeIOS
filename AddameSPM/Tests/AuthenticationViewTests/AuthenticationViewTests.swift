//
//  AuthenticationViewTests.swift
//  
//
//  Created by Saroar Khandoker on 17.09.2021.
//

import ComposableArchitecture
import KeychainService
import PhoneNumberKit
import AddaSharedModels

import SwiftUI
import Combine
import AuthClient

@testable import AuthenticationView
import XCTest

class AuthenticationViewTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testFlow_Success_WithValidPhoneNumber() {

    let state = LoginState()

    let environment = AuthenticationEnvironment(
      authClient: .happyPath, userDefaults: .live(),
      mainQueue: scheduler.eraseToAnyScheduler()
    )

    let store = TestStore(
      initialState: state,
      reducer: loginReducer,
      environment: environment
    )

    store.send(.sendPhoneNumberButtonTapped("+79218888888")) {
      $0.isLoginRequestInFlight = true
    }
    scheduler.advance()
    store.receive(
      .loninResponse(
        .success(
          .init(phoneNumber: "+79218888888",
                attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
                code: "336699")
        )
      )
    ) {
      $0.isLoginRequestInFlight = false
      $0.isValidationCodeIsSend = true
      $0.authResponse = AuthResponse(
        phoneNumber: "+79218888888",
        attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
        code: "336699"
      )
    }
    store.send(.verificationRequest("336699")) {
      if $0.authResponse.code!.count == 6 {
        $0.isLoginRequestInFlight = true
        $0.authResponse.code = "336699"
      }
    }
    scheduler.advance()
    store.receive(
      .verificationResponse(
        .success(.init(
          status: "online",
          user: User(
            id: "5fabb05d2470c17919b3c0e2",
            phoneNumber: "+79218888888",
            firstName: "AuthClientMock",
            createdAt: Date(), updatedAt: Date()
          ),
          access: AuthTokenResponse(accessToken: "", refreshToken: "")
        )
      )
    )
   )

  }

  func testFlow_Fail_WithInvalidPhoneNumber() {
    let authRes = AuthResponse(phoneNumber: "+7921888888")
    let state = LoginState()

    let environment = AuthenticationEnvironment(
      authClient: .failing, userDefaults: .live(),
      mainQueue: scheduler.eraseToAnyScheduler()
    )

    let store = TestStore(
      initialState: state,
      reducer: loginReducer,
      environment: environment
    )

    store.send(.sendPhoneNumberButtonTapped(authRes.phoneNumber)) {
      $0.isLoginRequestInFlight = false
    }

  }

  // swiftlint:disable function_body_length
  func testFlow_Fail_WithValidPhoneNumber_AndInvalidCode() {

    var authClient = AuthClient.failing
    authClient.login = { _ in
      Just(
        AuthResponse(
          phoneNumber: "+79218888888",
          attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
          code: "336699"
        )
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    }

    let state = LoginState()

    let environment = AuthenticationEnvironment(
      authClient: authClient, userDefaults: .live(),
      mainQueue: scheduler.eraseToAnyScheduler()
    )

    let store = TestStore(
      initialState: state,
      reducer: loginReducer,
      environment: environment
    )

    store.send(.sendPhoneNumberButtonTapped("+79218888888")) {
      $0.isLoginRequestInFlight = true
    }
    scheduler.advance()
    store.receive(
      .loninResponse(
        .success(
          .init(phoneNumber: "+79218888888",
                attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
                code: "336699")
        )
      )
    ) {
      $0.isLoginRequestInFlight = false
      $0.isValidationCodeIsSend = true
      $0.authResponse = AuthResponse(
        phoneNumber: "+79218888888",
        attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
        code: "336699"
      )
    }
    store.send(.verificationRequest("336699")) {
      if $0.authResponse.code!.count == 6 {
        $0.isLoginRequestInFlight = true
        $0.authResponse.code = "336699"
      }
    }
    scheduler.advance()
    store.receive(
      .verificationResponse(
        .failure(
          HTTPRequest.HRError.custom("verification fail", "")
        )
      )
    ) {
      $0.alert = .init(title: TextState("Please try again!") )
    }
  }
}
