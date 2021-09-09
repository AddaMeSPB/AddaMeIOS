//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import SharedModels

extension AuthClient {
  public static let happyPath = Self(
    login: { _ in
      Just(
        AuthResponse(
          phoneNumber: "+79218888888",
          attemptId: "165541EC-692E-440A-9CF8-565776E9DC99",
          code: "336699"
        )
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()

    },
    verification: { _ in
      Just(
        LoginRes(
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
      //        .map { res in
      //          KeychainService.save(codable: res.user, for: .user)
      //          KeychainService.save(codable: res.access, for: .token)
      //          return res
      //        }
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    }
  )

  public static let failing = Self(
    login: { _ in
      Fail(error: HTTPRequest.HRError.custom("Missing code", ""))
        .eraseToAnyPublisher()
    },
    verification: { _ in
      Fail(error: HTTPRequest.HRError.custom("verification fail", ""))
        .eraseToAnyPublisher()
    }
  )
}

extension String: Error {}
